{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE MultilineStrings #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE NoFieldSelectors #-}

import Control.Concurrent.Async (race)
import Control.Exception
import Control.Monad (forever)
import Data.Aeson
import Data.ByteString (toStrict)
import Data.ByteString.Char8 qualified as ByteString
import Data.Map.Strict (Map)
import Data.Map.Strict qualified as Map
import Data.Maybe (catMaybes)
import Data.Text (Text)
import Data.Text qualified as Text
import GHC.Generics
import System.IO (hFlush, stdin, stdout)
import System.Process

handleStdout colors stdout = do
  -- Ignore the first line and replace by advanced header
  _ <- ByteString.hGetLine stdout
  ByteString.putStrLn """{"version":1,"click_events": true}"""

  -- Passthrough the second one, it is an '['
  ByteString.putStrLn =<< ByteString.hGetLine stdout

  -- Start handling, first line is peculiar, it does not contain a leading commat
  handleLine colors =<< ByteString.hGetLine stdout

  forever $ do
    ByteString.putStr ","
    handleLine colors =<< ByteString.drop 1 <$> ByteString.hGetLine stdout

data Input = Input
  { name :: Text
  }
  deriving (Generic, FromJSON, Show)

handleStdin stdin = do
  -- Ignore the first line and replace by advanced header
  _ <- ByteString.hGetLine stdin
  --
  -- Start handling, first line is peculiar, it does not contain a leading commat
  handleInput =<< ByteString.hGetLine stdin

  forever $ do
    handleInput =<< ByteString.drop 1 <$> ByteString.hGetLine stdin

handleInput input_bs = do
  case decodeStrict @Input input_bs of
    Just input -> do
      case input.name of
        "dunst" -> callCommand "set-notification-pause toggle"
        "tailscaile" -> do
          status <- getCurrentTailscaleStatus

          case status of
            TailscaleOn -> callProcess "tailscale" ["down"]
            TailscaleOff -> callProcess "tailscale" ["up"]
            TailscaleLoggedOut -> pure ()
        "volume" -> callCommand "volume-change set-sink-mute @DEFAULT_SINK@ toggle"
        "wireless" -> callProcess "wifi-menu" []
        "bluetooth" -> callProcess "bz-menu" []
        _ -> pure ()
    Nothing -> pure ()

main = do
  colors <- parseColors
  (_stdin, stdout, _stderr, _pid) <- runInteractiveProcess "i3status" [] Nothing Nothing

  race (handleStdout colors stdout) $
    race (handleStdin stdin) watch_window_title_update

watch_window_title_update = do
  (_stdin, stdout, _stderr, _pid) <- runInteractiveProcess "swaymsg" ["-t", "subscribe", "-m", """["window"]"""] Nothing Nothing
  forever $ do
    _ <- ByteString.hGetLine stdout
    callCommand "killall -USR1 i3status"
  

handleLine :: Colors -> ByteString.ByteString -> IO ()
handleLine colors bs = case eitherDecodeStrict @[Item] bs of
  Left err -> error err
  Right items -> do
    dunst <- dunstM colors
    title <- titleM colors
    bluetooth <- bluetooth_statusM colors
    recording <- recordingM colors
    ps_controler_status <- ps_controler_statusM colors
    tailscale <- tailscaleM colors
    let items_colors_fixed = map (fixColor colors) items
    let object' = catMaybes [title, recording, ps_controler_status, bluetooth, tailscale, dunst] <> items_colors_fixed
    ByteString.putStrLn (toStrict $ encode object')
    hFlush stdout

fixColor :: Colors -> Item -> Item
fixColor colors item = item {color = new_color <$> item.color}
  where
    new_color "#FF0000" = colors.critical
    new_color "#00FF00" = colors.normal
    new_color "#FFFF00" = colors.important
    new_color "#FFFFFF" = colors.foreground
    new_color e = error $ "No color for: " <> show e

data Item = Item
  { name :: Text,
    color :: Maybe Text,
    full_text :: Text
  }
  deriving (Show, ToJSON, FromJSON, Generic)

-- | Represents the colors I care about
--
-- TODO: the naming sucks and should be improved
data Colors = Colors
  { critical :: Text,
    important :: Text,
    normal :: Text,
    foreground :: Text
  }

parseColors :: IO Colors
parseColors = do
  Just colors <- decodeFileStrict @(Map Text Text) "/home/guillaume/.config/theme.json"
  pure $
    Colors
      { critical = colors Map.! "color1",
        important = colors Map.! "color11",
        normal = colors Map.! "color10",
        foreground = colors Map.! "foreground"
      }

dunstM colors = do
  (ByteString.strip -> status) <- ByteString.pack <$> readProcess "dunstctl" ["is-paused"] ""

  let (color, message)
        | status == "true" = (colors.critical, "Notifications: OFF" :: Text)
        | otherwise = (colors.normal, "Notifications: ON")

  pure $ Just $ Item {name = "dunst", color = Just color, full_text = message}

titleM colors = do
  (Text.strip . Text.pack -> window_title) <- readCreateProcess (shell "swaymsg -t get_tree 2>/dev/null | jq -r '..|try select(.focused == true).name' 2>/dev/null") ""

  pure $ Just $ Item {name = "title", color = Just colors.foreground, full_text = window_title}

bluetooth_statusM :: Colors -> IO (Maybe Item)
bluetooth_statusM colors = do
  status <- (Text.strip . Text.pack) <$> readProcess "dmenu-bluetooth" ["--status"] ""

  let color = if status == "\62099" then colors.normal else colors.foreground

  pure $ Just $ Item {name = "bluetooth", color = Just color, full_text = status}

recordingM colors = do
  timeElapsedM <- try @IOError $ readProcess "ps" ["-C", "wl-screenrec", "h", "-o", "etime"] ""
  case timeElapsedM of
    Left _ -> pure Nothing
    Right timeElapsed -> do
      -- TODO: during the recording, we may regularly SIGUSR ourself in order to refresh
      pure $ Just $ Item {name = "recording", color = Just colors.important, full_text = (Text.pack "Recording: ") <> Text.strip (Text.pack timeElapsed)}

-- TODO
-- status=$(upower -i /org/freedesktop/UPower/devices/battery_ps_controller_battery_84o30o95o16o8eod8 | rg -o1 'percentage:.*?([0-9]+)%')
-- upower -i /org/freedesktop/UPower/devices/battery_ps_controller_battery_84o30o95o16o8eod8 | grep 'should be ignocritical' > /dev/null
-- if [ $? -eq 0 ]
-- then
--   ps_controler_status=''
-- else
--   if [ "$status" -eq "100" ]
--   then
--       color=$normal
--   elif [ "$status" -gt "50" ]
--   then
--     color=$white
--   elif [ "$status" -gt "20" ]
--   then
--     color=$important
--   else
--     color=$critical
--   fi
--   ps_controler_status='{"name":"ps_controler","instance":"ps_controler","color":"'"$color"'","markup":"none","full_text":"  '"$status%"'"},'
-- fi
ps_controler_statusM :: Colors -> IO (Maybe a)
ps_controler_statusM _ = pure Nothing

data TailscaleStatus = TailscaleOn | TailscaleOff | TailscaleLoggedOut

getCurrentTailscaleStatus = do
  statusM <- (fmap $ Text.strip . Text.pack) <$> try @IOError (readProcess "tailscale" ["status"] "")

  case statusM of
    Left _ -> pure TailscaleLoggedOut
    Right status -> pure $ do
      if
        | "Tailscale is stopped" `Text.isInfixOf` status -> TailscaleOff
        | "Logged out." `Text.isInfixOf` status -> TailscaleLoggedOut
        | otherwise -> TailscaleOn

tailscaleM :: Colors -> IO (Maybe Item)
tailscaleM colors = do
  status <- getCurrentTailscaleStatus

  let (color, full_text) = case status of
        TailscaleOff -> (colors.foreground, "VPN: OFF")
        TailscaleLoggedOut -> (colors.important, "VPN: LOGGED OUT")
        TailscaleOn -> (colors.normal, "VPN: ON")

  pure $ Just $ Item {name = "tailscale", color = Just color, full_text = full_text}

-- TODO
-- - subscribe for swamsg window title (More generally, force the "refresh")
-- - refresh when "recording"
-- - Code cleaning (especially the colors naming)
-- - Possibly replace the i3status widgets by my own
