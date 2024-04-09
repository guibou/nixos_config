local utils = require "mp.utils"

function srt_time_to_seconds(time)
    local major, minor = time:match("(%d%d:%d%d:%d%d),(%d%d%d)")
    local hours, mins, secs = major:match("(%d%d):(%d%d):(%d%d)")
    return hours * 3600 + mins * 60 + secs + minor / 1000
end

function seconds_to_srt_time(time)
    local hours = math.floor(time / 3600)
    local mins = math.floor(time / 60) % 60
    local secs = math.floor(time % 60)
    local milliseconds = (time * 1000) % 1000

    return string.format("%02d:%02d:%02d,%03d", hours, mins, secs, milliseconds)
end

function seconds_to_time_string(duration, flag)
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(duration / 60 % 60)
    local seconds = math.floor(duration % 60)
    local milliseconds = (duration * 1000) % 1000
    if not flag then
        return string.format("%02d:%02d:%02d.%03d", hours, minutes, seconds, milliseconds)
    else
        return string.format("%02d.%02d.%02d", hours, minutes, seconds)
    end
end

function set_start_timestamp()
    start_timestamp = mp.get_property_number("time-pos")
    mp.osd_message("Start: " .. seconds_to_time_string(start_timestamp), 1)
end

function set_end_timestamp()
    end_timestamp = mp.get_property_number("time-pos")
    mp.osd_message("End: " .. seconds_to_time_string(end_timestamp), 1)
end

function cut_video_fragment()
    working_dir = mp.get_property("working-directory")
    video_path = mp.get_property("path")
    video_file = mp.get_property("filename")
    video_filename = mp.get_property("filename/no-ext")

    set_end_timestamp()

    if start_timestamp ~= nil and end_timestamp ~= nil and start_timestamp < end_timestamp then
        mp.osd_message("Encoding Video from " .. seconds_to_time_string(start_timestamp) .. " to " .. seconds_to_time_string(end_timestamp), 2)

        t = end_timestamp - start_timestamp

        video_absolute_path = working_dir .. "/" .. video_file

        filename = table.concat{
            working_dir,
            "/",
            video_filename,
            ".",
            seconds_to_time_string(start_timestamp, true),
            "-",
            seconds_to_time_string(end_timestamp, true)
        }

        args = {
            "ffmpeg",
	    "-i",
	    video_absolute_path,
            "-ss", start_timestamp,
	    "-to", end_timestamp,
	    "-c", "copy",
	    working_dir .. "/" .. video_file .. "_cut.MP4"
        }

        utils.subprocess_detached({ args = args, cancellable = false })
    end
end

mp.add_key_binding("ctrl+w", "set-start-timestamp", set_start_timestamp)
mp.add_key_binding("ctrl+e", "set-end-timestamp", cut_video_fragment)
