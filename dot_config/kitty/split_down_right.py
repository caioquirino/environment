# New split inheriting CWD, alternating by window count in the tab:
# below, side, below, side, ...
from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    tab = boss.active_tab
    count = len(tab) if tab is not None else 1
    location = 'hsplit' if count % 2 else 'vsplit'
    boss.launch('--cwd=current', f'--location={location}')
