local default_gui = data.raw["gui-style"].default

data:extend({
    {
        type = "font",
        name = "todo_font_default",
        from = "default",
        size = 14
    },
    {
        type = "font",
        name = "todo_font_semibold",
        from = "default-semibold",
        size = 14
    },
    {
        type = "font",
        name = "todo_font_subheading",
        from = "default",
        size = 18
    },
    {
        type = "font",
        name = "todo_font_smaller",
        from = "default",
        size = 13
    }
})

default_gui["todo_table_default"] = {
    type = "table_style",
}

default_gui["todo_button_default"] = {
    type = "button_style",
    font = "todo_font_default",
    align = "center",
    vertical_align = "center"
}

default_gui["todo_button_sort"] = {
    type = "button_style",
    font = "todo_font_default",
    align = "center",
    vertical_align = "center",
    width = 40
}

default_gui["todo_sprite_button_default"] = {
    type = "button_style",
    parent = "tool_button",
    font = "todo_font_default",
    align = "center",
    vertical_align = "center",
    height = 36
}

-- White font, padding on right, for use next to close button in header
default_gui["todo_in_title_button_default"] = {
    type = "button_style",
    parent = "frame_action_button",
    right_margin = 4,
    default_font_color = {1, 1, 1} 
}

default_gui["todo_label_default"] = {
    type = "label_style",
    font = "todo_font_default",
}

default_gui["todo_label_task"] = {
    type = "label_style",
    font = "todo_font_default",
    single_line = false
}

default_gui["todo_label_title_task"] = {
    type = "label_style",
    font = "todo_font_semibold",
    single_line = false
}

default_gui["todo_label_subtask"] = {
    type = "label_style",
    font = "todo_font_smaller",
    single_line = false
}

default_gui["todo_textbox_default"] = {
    type = "textbox_style",
    font = "todo_font_default",
    minimal_width = 300,
    minimal_height = 100,
}

default_gui["todo_textfield_default"] = {
    type = "textbox_style",
    font = "todo_font_default",
    minimal_width = 300
}

default_gui["todo_base64_textbox"] = {
    type = "textbox_style",
    font = "todo_font_default",
    minimal_width = 300,
    minimal_height = 100,
    maximal_width = 500,
    maximal_height = 400
}

default_gui["todo_dropdown_default"] = {
    type = "dropdown_style",
    font = "todo_font_default",
}

default_gui["todo_frame_add_where"] = {
    type = "frame_style",
    font = "todo_font_subheading"
}

default_gui["todo_checkbox_default"] = {
    type = "checkbox_style",
    font = "todo_font_default",
    maximal_width = 500,
}

default_gui["todo_checkbox_subtask"] = {
    type = "checkbox_style",
    parent = "todo_checkbox_default",
    font = "todo_font_smaller",
    single_line = false
}

default_gui["todo_checkbox_in_title"] = {
    type = "checkbox_style",
    parent = "todo_checkbox_default",
    font = "todo_font_default",
    size = 24,
    margin = 0
}

default_gui["todo_radiobutton_default"] = {
    type = "radiobutton_style",
    font = "todo_font_default"
}