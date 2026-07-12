{-# LANGUAGE ViewPatterns #-}

-- \| This depends on jq and swaymsg

import Control.Concurrent.Async (cancel, race, wait, withAsync)
import System.Process

getWindows = do
  (lines -> all_windows) <-
    readCreateProcess
      ( shell
          "swaymsg -t get_tree | jq -r '.. | select(.visible?) | \"\\(.rect.x),\\(.rect.y) \\(.window_rect.width)x\\(.window_rect.height) Window: \\(.foreign_toplevel_identifier)\"'"
      )
      ""

  output <-
    readCreateProcess
      ( shell
          "swaymsg -t get_outputs --raw | jq -jr '.[0] | \"\\(.rect.x),\\(.rect.y) \\(.rect.width)x\\(.rect.height) Monitor: \\(.name)\"'"
      )
      ""

  -- slurp will return the smallest region, so unless you are doing the
  -- selection in fullscreen, if your mouse is on a window, it will pick the
  -- window, otherwise, it will pick the monitor.
  let query = output : all_windows
  pure query

-- | Select a window with slurp based on what's visible on the current
-- workspace
selectWindow query = do
  res <-
    readCreateProcess
      ( proc
          "slurp"
          [ "-r",
            "-f",
            "%l",
            "-s",
            "ff000022"
          ]
      )
      (unlines query)
  pure res

-- | block until sway notify about any change
--
-- This is naive and will notify a lot of possible changes
wait_for_workspace_change = do
  readCreateProcess (proc "swaymsg" ["-t", "subscribe", "[\"workspace\",\"window\",\"binding\"]"]) ""

main = do
  let loop query = do
        state <- withAsync (selectWindow query) $ \async -> do
          let eventLoop = do
                -- Select a window, but chnage selection option if anythnig change in sway
                res <- race wait_for_workspace_change (wait async)
                case res of
                  Left {} -> do
                    -- Recover the current configuration, if anything changed,
                    -- we rerun slurp. Otherwise, we continue waiting.
                    query' <- getWindows
                    if query' == query
                      then do
                        eventLoop
                      else do
                        pure (Left query')
                  Right res -> do
                    pure (Right res)
          eventLoop

        case state of
          Right res -> do
            pure res
          Left query' -> loop query'
  putStrLn =<< loop =<< getWindows
