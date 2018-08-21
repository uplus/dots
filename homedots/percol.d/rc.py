from percol.finder import FinderMultiQueryMigemo

FinderMultiQueryMigemo.dictionary_path = '/usr/share/cmigemo/utf-8/migemo-dict'
FinderMultiQueryMigemo.minimum_query_length = 2

# Run command file for percol
percol.view.PROMPT  = r"<bold><cyan>[percol]</cyan>:</bold> %q"
percol.view.CANDIDATES_LINE_SELECTED = ("on_green", "black")
percol.view.CANDIDATES_LINE_QUERY    = ("on_yellow", "black")

# Display finder name in RPROMPT
percol.view.prompt_replacees["F"] = lambda self, **args: self.model.finder.get_name()
percol.view.RPROMPT = r"\<%F\> (%i/%I) [%n/%N]"

percol.import_keymap({
    "C-h": lambda percol: percol.command.delete_backward_char(),
    "C-d": lambda percol: percol.command.delete_forward_char(),
    "C-a": lambda percol: percol.command.beginning_of_line(),
    "C-e": lambda percol: percol.command.end_of_line(),
    "C-f": lambda percol: percol.command.forward_char(),
    "C-b": lambda percol: percol.command.backward_char(),
    "C-n": lambda percol: percol.command.select_next(),
    "C-p": lambda percol: percol.command.select_previous(),
    "C-k": lambda percol: percol.command.kill_end_of_line(),

    # "C-y": lambda percol: percol.command.yank(),
    "C-y": lambda percol: percol.command.mark_all(),
    "C-v": lambda percol: percol.command.select_next_page(),
    "M-v": lambda percol: percol.command.select_previous_page(),
    "M-<": lambda percol: percol.command.select_top(),
    "M->": lambda percol: percol.command.select_bottom(),

    "C-m": lambda percol: percol.finish(),
    "C-j": lambda percol: percol.finish(),
    "C-g": lambda percol: percol.cancel(),

    "M-c": lambda percol: percol.command.toggle_case_sensitive(),
    "M-m": lambda percol: percol.command.toggle_finder(FinderMultiQueryMigemo),
    "M-r": lambda percol: percol.command.toggle_finder(FinderMultiQueryRegex),
})
