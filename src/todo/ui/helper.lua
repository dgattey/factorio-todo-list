-- No individual text element should be wider than this - helps with wrapping of labels and checkboxes
MAX_TEXT_ELEMENT_WIDTH = 500

local TITLE_BAR_NAME = 'title_bar'

-- Creates the contents of the title bar, adding the caption + close button if provided
function todo.populate_title_bar(player, frame, title_bar, name, caption, close_name)
    -- Left side of the bar has the title itself (and is draggable)
    local title = title_bar.add({
        type = "label",
        caption = caption,
        style = "frame_title"
    })
    title.style.maximal_width = MAX_TEXT_ELEMENT_WIDTH
    title.drag_target = frame

    -- Add 'dragger' (filler) between title and (close) buttons
    local dragger = title_bar.add({
        type = "empty-widget",
        style = "draggable_space_header"
    })
    dragger.style.vertically_stretchable = true
    dragger.style.horizontally_stretchable = true
    dragger.drag_target = frame

    -- Right side of the bar has the close button if defined
    if close_name ~= nil then
        title_bar.add({
            type = "sprite-button",
            style = "frame_action_button",
            sprite = "utility/close_white",
            name = close_name
        })
    end
end

-- Creates a frame, adding a title bar to it
function todo.create_frame(player, name, caption, close_name)
    local frame = player.gui.screen.add({
        type = "frame",
        name = name,
        direction = "vertical"
    })

    -- Add title bar with a computed name for use later + populate it
    local title_bar = frame.add({
        type = "flow",
        name = TITLE_BAR_NAME
    })
    todo.populate_title_bar(player, frame, title_bar, name, caption, close_name)

    return frame
end

-- Assumes the frame + title in the frame have been created already! Used to update
-- the title bar if anything needs to change.
function todo.update_titlebar_of_frame(player, frame_name, caption, close_name)
    local frame = player.gui.screen[frame_name]
    local title_bar = frame[TITLE_BAR_NAME]
    for _, element in pairs(title_bar.children) do
        element.destroy()
    end
    todo.populate_title_bar(player, frame, title_bar, name, caption, close_name)
end