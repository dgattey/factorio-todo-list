-- This file also contains the maximize button

function todo.create_maximize_button(player)
    todo.log("Creating Basic UI for player " .. player.name)

    if (not todo.get_maximize_button(player)
            and not todo.get_main_frame(player)
            and todo.should_show_maximize_button(player)) then
        mod_gui.get_button_flow(player).add({
            type = "button",
            style = "todo_button_default",
            name = "todo_maximize_button",
            caption = { todo.translate(player, "todo_list")},
        })
    end
end

function todo.create_maximized_frame(player)
    local frame = todo.create_frame(player, "todo_main_frame", { todo.translate(player, "todo_list") }, "todo_minimize_button")

    todo.create_task_table(frame, player)

    local flow = frame.add({
        type = "flow",
        name = "todo_main_button_flow",
        direction = "horizontal"
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_open_add_dialog_button",
        caption = { todo.translate(player, "add") }
    })

    flow.add({
        type = "button",
        style = "todo_button_default",
        name = "todo_toggle_show_completed_button",
        caption = { todo.translate(player, "show_done") }
    })

    flow.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_open_export_dialog_button",
        sprite = "utility/export",
        tooltip = { todo.translate(player, "export") }
    })
    todo.update_export_dialog_button_state()

    flow.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_open_import_dialog_button",
        sprite = "utility/import",
        tooltip = { todo.translate(player, "import") }
    })

    frame.force_auto_center()

    return frame
end

function todo.create_task_table(frame, player)

    local scroll = frame.add({
        type = "scroll-pane",
        name = "todo_scroll_pane"
    })

    scroll.vertical_scroll_policy = "auto"
    scroll.horizontal_scroll_policy = "never"
    scroll.style.height = todo.get_window_height(player)
    
    local table = scroll.add({
        type = "table",
        style = "todo_table_default",
        name = "todo_task_table",
        column_count = 9,
        -- TODO: put this behind an option?
        draw_horizontal_line_after_headers = true
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_done",
        caption = { "", { "todo.title_done" }, "   " }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_task",
        caption = { todo.translate(player, "title_task") }
    })
    -- Only show the assignee column if we allow task ownership currently
    if todo.is_task_ownership(player) then
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_title_assignee",
            caption = { todo.translate(player, "title_assignee")}
        })
    else 
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_title_assignee",
            caption = ""
        })
    end

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_top",
        caption = "Sort"
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_up",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_down",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_bottom",
        caption = ""
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_edit",
        caption = { todo.translate(player, "title_edit") }
    })

    table.add({
        type = "label",
        style = "todo_label_default",
        name = "todo_title_details",
        caption = { "todo.title_details" }
    })

    return table
end

-- Adds just the details + subtasks of a task to a table.
-- If you're adding these somewhere outside the main task list,
-- provide an add_task_suffix, otherwise you won't be able to
-- distiguish between the main add button and your new one when
-- adding subtasks. Don't forget to register the new click event.
function todo.add_task_details_to_table(player, table, task, add_task_suffix)

    -- Add a row for the description/details in small font if it's there
    if (task.task and string.len(task.task) > 0) then
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_main_expanded_1_" .. task.id,
            caption = ""
        })
        local task_description = table.add({
            type = "label",
            style = "todo_label_subtask",
            name = "todo_main_expanded_task_label_" .. task.id,
            caption = "[color=#CCCCCC]" .. task.task .. "[/color]"
        })
        task_description.style.maximal_width = MAX_TEXT_ELEMENT_WIDTH
        task_description.style.bottom_padding = 6

        -- fill up the row with empty cells
        for _, i in pairs({ 2, 3, 4, 5, 6, 7, 8 }) do
            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_main_expanded_" .. i .. "_" .. task.id,
                caption = ""
            })
        end
    end

    -- Adds all subtasks + a row to add a new one
    todo.add_subtasks_to_task_table(player, table, task, add_task_suffix)

    -- Add mostly empty row to make visual spacing between bottom of subtasks and the next task
    local row = {{
        type = "flow",
        name = "todo_task_spacer" .. task.id,
    }}
    todo.add_row_to_main_table(table, row)
end

-- Adds a full task + its details + subtasks if expanded
function todo.add_task_to_table(player, table, task, completed, is_first, is_last, expanded)
    local id = task.id

    local checkbox_name
    if (completed) then
        checkbox_name = "todo_main_task_mark_open_checkbox_"
    else
        checkbox_name = "todo_main_task_mark_complete_checkbox_"
    end
    table.add({
        type = "checkbox",
        name = checkbox_name .. id,
        state = completed
    })
    local task_title = table.add({
        type = "label",
        style = "todo_label_title_task",
        name = "todo_main_task_title_" .. id,
        caption = task.title
    })
    task_title.style.width = 100
    task_title.style.maximal_width = MAX_TEXT_ELEMENT_WIDTH

    -- Only show the assignee cell if we allow ownership (otherwise blank)
    if todo.is_task_ownership(player) then
        if (task.assignee) then
            table.add({
                type = "label",
                style = "todo_label_default",
                name = "todo_main_task_assignee_" .. id,
                caption = task.assignee
            })
        else
            table.add({
                type = "button",
                style = "todo_button_default",
                name = "todo_take_task_button_" .. id,
                caption = { todo.translate(player, "assign_self") }
            })
        end
    else
        table.add({
            type = "label",
            style = "todo_label_default",
            name = "todo_main_task_assignee_" .. id,
            caption = ""
        })
    end

    if (is_first) then
        table.add({
            type = "label",
            name = "todo_item_firsttop_" .. id,
            caption = ""
        })
        table.add({
            type = "label",
            name = "todo_item_firstup_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_sort",
            name = "todo_main_task_move_top_" .. id,
            caption = "↟"
        })
        table.add({
            type = "button",
            style = "todo_button_sort",
            name = "todo_main_task_move_up_" .. id,
            caption = "↑"
        })
    end

    if (is_last) then
        table.add({
            type = "label",
            name = "todo_item_lastdown_" .. id,
            caption = ""
        })
        table.add({
            type = "label",
            name = "todo_item_lastbottom_" .. id,
            caption = ""
        })
    else
        table.add({
            type = "button",
            style = "todo_button_sort",
            name = "todo_main_task_move_down_" .. id,
            caption = "↓"
        })
        table.add({
            type = "button",
            style = "todo_button_sort",
            name = "todo_main_task_move_bottom_" .. id,
            caption = "↡"
        })
    end

    table.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_open_edit_dialog_button_" .. id,
        sprite = "utility/rename_icon_normal",
        tooltip = { todo.translate(player, "title_edit") }
    })

    -- Create a details section, with open or closed button, and a breakout button next to it. Has subtasks below if expanded
    local flow = table.add({
        type = "flow",
        name = "todo_details_flow_" .. id,
        direction = "horizontal"
    })
    if (expanded) then
        flow.add({
            type = "sprite-button",
            style = "todo_sprite_button_default",
            name = "todo_main_close_details_button_" .. id,
            sprite = "utility/speed_up",
            tooltip = { "todo.title_details" }
        })
        todo.add_task_details_to_table(player, table, task)
    else
        flow.add({
            type = "sprite-button",
            style = "todo_sprite_button_default",
            name = "todo_main_open_details_button_" .. id,
            sprite = "utility/speed_down",
            tooltip = { "todo.title_details" }
        })
    end
    flow.add({
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_breakout_button_" .. id,
        sprite = "utility/export_slot",
        tooltip = { "todo.breakout_task" }
    })
end

-- Use the add_task_suffix when you are placing subtasks outside the main todo list table
function todo.add_subtasks_to_task_table(player, table, task, add_task_suffix)
    -- for each subtask
    if (task.subtasks) then
        local open_subtask_count = #task.subtasks.open
        for i, subtask in ipairs(task.subtasks.open) do
            todo.add_subtask_to_main_table(player, table, task.id, subtask, i == 1, i == open_subtask_count)
        end

        local done_subtask_count = #task.subtasks.done
        for i, subtask in ipairs(task.subtasks.done) do
            -- completed subtasks have ids that are "after" the open list.
            -- With this information it is possible to distinguish open from done tasks without
            -- transferring this information accross the functions
            todo.add_subtask_to_main_table(player, table, task.id, subtask, i == 1, i == done_subtask_count, true)
        end
    end

    -- add new subtask, using suffix if it exists
    local full_id = task.id
    if add_task_suffix ~= nil then
        full_id = add_task_suffix .. task.id
    end
    local row = { "done", "task", "take", "top", "up", "down", "bottom", "edit", "delete" }
    todo.log("todo_main_subtask_new_text_" .. full_id)

    row[2] = {
        type = "textfield",
        style = "todo_textfield_default",
        name = "todo_main_subtask_new_text_" .. full_id
    }

    row[8] = {
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = "todo_main_subtask_save_new_button_" .. full_id,
        sprite = "utility/add",
        tooltip = { todo.translate(player, "add_subtask") }
    }
    todo.add_row_to_main_table(table, row)

end

function todo.add_subtask_to_main_table(player, table, task_id, subtask, is_first, is_last, done)

    -- if not provided we assume tasks are open
    done = done or false
    local subtask_id = subtask.id

    -- This is done everywhere again to serve as readable reference to how the table is laid out.
    -- The downside is that you have to change this everywhere should the table change. But.. readability :)
    local row = { "done", "task", "take", "top", "up", "down", "bottom", "edit", "delete" }

    row[2] = {
        type = "checkbox",
        style = "todo_checkbox_subtask",
        name = string.format("todo_main_subtask_checkbox_%i_%i", task_id, subtask_id),
        state = done,
        caption = subtask.task,
        tooltip = subtask.task
    }

    -- completed subtasks cannot be sorted or edited
    if (not done) then
        if (not is_first) then
            row[5] = {
                type = "button",
                style = "todo_button_sort",
                name = string.format("todo_main_subtask_move_up_%i_%i", task_id, subtask_id),
                caption = "↑"
            }
        end

        if (not is_last) then
            row[6] = {
                type = "button",
                style = "todo_button_sort",
                name = string.format("todo_main_subtask_move_down_%i_%i", task_id, subtask_id),
                caption = "↓"
            }
        end

        row[8] = {
            type = "sprite-button",
            style = "todo_sprite_button_default",
            name = string.format("todo_main_subtask_edit_button_%i_%i", task_id, subtask_id),
            sprite = "utility/rename_icon_normal",
            tooltip = { todo.translate(player, "edit_subtask") }
        }
    end

    row[9] = {
        type = "sprite-button",
        style = "todo_sprite_button_default",
        name = string.format("todo_main_subtask_delete_button_%i_%i", task_id, subtask_id),
        sprite = "utility/trash",
        tooltip = { todo.translate(player, "delete_subtask") }
    }

    todo.add_row_to_main_table(table, row)
end

function todo.get_main_frame(player)
    local flow = player.gui.screen
    if flow.todo_main_frame then
        return flow.todo_main_frame
    else
        return nil
    end
end

function todo.get_task_table(player)
    local main_frame = todo.get_main_frame(player)
    if (main_frame.todo_task_table) then
        return main_frame.todo_task_table
    elseif (main_frame.todo_scroll_pane.todo_task_table) then
        return main_frame.todo_scroll_pane.todo_task_table
    end
end

function todo.add_row_to_main_table(table, values)
    local index = 1
    for i, value in ipairs(values) do
        index = i

        if (type(value) == "string") then
            table.add(todo.main_create_filler_element(#table.children))
        else
            todo.log(string.format("Adding child with name [%s]", value.name))
            table.add(value)
        end
    end

    for i = index + 1, table.column_count do
        table.add(todo.main_create_filler_element(#table.children))
    end
end

function todo.main_create_filler_element(count)
    local name = string.format("todo_main_filler_%i", count + 1)
    todo.log(string.format("Creating filler with name [%s].", name))
    return {
        type = "label",
        style = "todo_label_default",
        name = name,
        caption = ""
    }
end
