local FRAME_NAME_PREFIX = "todo_breakout_window_"
local CLOSE_NAME_PREFIX = "todo_minimize_breakout_window_"
local FRAME_TITLE = "title_breakout_window"
local SCROLL_PANE_NAME = "todo_breakout_scroll_pane"
local TABLE_NAME = "todo_breakout_table"

-- Grabs a task and creates the title elements
function todo.get_breakout_title_elements(player, id)
    local _, task_state = todo.get_task_by_id(id)
    local is_checkbox_checked = false
    local checkbox_name = "todo_main_task_mark_complete_checkbox_"
    if task_state == 'done' then
        is_checkbox_checked = true
        checkbox_name = "todo_main_task_mark_open_checkbox_"
    end

    local task_checkbox = {
        type = "checkbox",
        name = checkbox_name .. id,
        state = is_checkbox_checked,
        style = "todo_checkbox_in_title",
        tooltip = { todo.translate(player, "breakout_checkbox_tooltip") }
    }

    local edit_button = {
        type = "sprite-button",
        style = "todo_in_title_button_default",
        name = "todo_open_edit_dialog_button_" .. id,
        sprite = "utility/rename_icon_small_white",
        tooltip = { todo.translate(player, "title_edit") }
    }

    return { task_checkbox }, { edit_button }
end

-- Populates the breakout task elements on the table
function todo.add_breakout_task_elements(player, id)
    local table = todo.get_breakout_window_table(player, id)
    local task = todo.get_task_by_id(id)
    -- The suffix here ensures we have a different id than the main table for our button
    todo.add_task_details_to_table(player, table, task, 'breakout_')
end

-- Opens details of one task (denoted by id) in a breakout window to see details at a quick glance and check off task + subtasks
function todo.create_breakout_window(player, id)
    local old_dialog = todo.get_breakout_window(player, id)
    if (old_dialog ~= nil) then
        old_dialog.destroy()
    end

    -- Grabs a task, creates a dialog with a complicated title bar based on the task itself
    local task = todo.get_task_by_id(id)
    local pretitle_elements, preclose_elements = todo.get_breakout_title_elements(player, id)
    local dialog = todo.create_frame(player,  FRAME_NAME_PREFIX .. id, { todo.translate(player, FRAME_TITLE), task.title }, CLOSE_NAME_PREFIX .. id, pretitle_elements, preclose_elements)
    
    -- Scrollable table for the contents of the task itself
    local scroll = dialog.add({
        type = "scroll-pane",
        name = SCROLL_PANE_NAME
    })
    scroll.vertical_scroll_policy = "auto"
    scroll.horizontal_scroll_policy = "never"
    scroll.style.maximal_height = todo.get_window_height(player) / 2
    scroll.style.minimal_height = scroll.style.maximal_height
    scroll.style.minimal_width = 250

    local table = scroll.add({
        type = "table",
        style = "todo_table_default",
        name = TABLE_NAME,
        column_count = 9
    })
    todo.add_breakout_task_elements(player, id)
    dialog.force_auto_center()
end

-- For every task, if there's a breakout window for it, refresh
function todo.refresh_breakout_windows(player)
    for _, task in pairs(global.todo.open) do
        todo.refresh_breakout_window(player, task.id)
    end
    for _, task in pairs(global.todo.done) do
        todo.refresh_breakout_window(player, task.id)
    end
end

-- If the window is open for a given task, refresh its contents
function todo.refresh_breakout_window(player, id)
    if todo.get_breakout_window_table(player, id) == nil then
        return
    end

    -- Update the title based on current version of task
    local task = todo.get_task_by_id(id)
    local pretitle_elements, preclose_elements = todo.get_breakout_title_elements(player, id)
    todo.update_titlebar_of_frame(player, FRAME_NAME_PREFIX .. id, { todo.translate(player, FRAME_TITLE), task.title }, CLOSE_NAME_PREFIX .. id, pretitle_elements, preclose_elements)

    -- Delete the elements in the table and recreate
    for _, element in pairs(todo.get_breakout_window_table(player, id).children) do
        element.destroy()
    end
    todo.add_breakout_task_elements(player, id)
end

function todo.get_breakout_window(player, id)
    local frame = player.gui.screen[FRAME_NAME_PREFIX .. id]
    if (frame and frame.visible) then
        return frame
    end
end

function todo.get_breakout_window_table(player, id)
    local frame = todo.get_breakout_window(player, id)
    if (frame) then
        if (frame[SCROLL_PANE_NAME]) then
            return frame[SCROLL_PANE_NAME][TABLE_NAME]
        end
    end
end

function todo.close_breakout_window(player, id)
    local frame = todo.get_breakout_window(player, id)
    if (frame) then
        frame.destroy()
    end
end