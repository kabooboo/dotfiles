#!/usr/bin/env python3

import os
import tomllib
import subprocess
import json
from pathlib import Path
from contextlib import suppress
import sys

from typing import TypedDict

AEROSPACE_CONFIG = Path(os.environ["HOME"]) / ".config" / "aerospace" / "aerospace.toml"

Monitor = TypedDict("Monitor", {
    "monitor-id": int,
    "monitor-name": str,
})

Workspace = TypedDict("Workspace", {
    "monitor-id": int,
    "monitor-name": str,
    "workspace": str,
    "workspace-is-focused": bool,
    "workspace-is-visible": bool,
})

Window = TypedDict("Window", {
    "monitor-id": int,
    "monitor-name": str,
    "workspace": str,
    "workspace-is-focused": bool,
    "workspace-is-visible": bool,
    "app-name": str,
    "app-pid": int,
    "app-bundle-id": int,
    "window-is-fullscreen": bool,
    "window-id": int,
    "window-title": str,
})

def run(cmd) -> str:
    result = subprocess.run(
        cmd, capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"ERROR running {' '.join(cmd)}: {result.stderr}")
        raise RuntimeError(f"Command failed: {' '.join(cmd)}")
    return result.stdout

def run_json(cmd) -> dict:
    result = subprocess.run(
        cmd + ["--json"], capture_output=True, text=True
    )
    if result.returncode != 0:
        print(f"ERROR running {' '.join(cmd)}: {result.stderr}")
        raise RuntimeError(f"Command failed: {' '.join(cmd)}")
    if not result.stdout.strip():
        print(f"ERROR: No output from {' '.join(cmd)} --json")
        raise RuntimeError(f"No output from {' '.join(cmd)} --json")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as e:
        print(f"ERROR: Could not parse JSON output from {' '.join(cmd)} --json")
        print("Output was:", repr(result.stdout))
        raise

def load_assignments(config_path) -> dict:
    with config_path.open("rb") as f:
        data = tomllib.load(f)
    return data.get("workspace-to-monitor-force-assignment", {})

def get_monitors() -> list[Monitor]:
    return run_json(["aerospace", "list-monitors", "--format", r"%{monitor-id} %{monitor-name}"])

def get_windows() -> list[Window]:
    return run_json(["aerospace", "list-windows", "--all",  "--format", r"%{window-id} %{window-title} %{window-is-fullscreen} %{app-bundle-id} %{app-name} %{app-pid} %{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-id} %{monitor-name}"])


def get_focused_window() -> Window | None:
    try:
        return run_json(["aerospace", "list-windows", "--focused",  "--format", r"%{window-id} %{window-title} %{window-is-fullscreen} %{app-bundle-id} %{app-name} %{app-pid} %{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-id} %{monitor-name}"])[0]
    except Exception:
        return None


def get_workspaces() -> list[Workspace]:
    return run_json(["aerospace", "list-workspaces", "--all", "--format", r"%{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-id} %{monitor-name}"])


def compose_workspace_sequences(*, monitors: list[Monitor], workspaces: list[Workspace]) -> dict[int, list[Workspace]]:
    """
    Create a dict containing monitor_ids as keys, and lists of workspaces as values.
    These are the values of the workspaces that are bound to that given screen.
    """
    # Load assignments from config
    assignments = load_assignments(AEROSPACE_CONFIG)
    # Get all monitors
    monitor_groups: dict[int, list[Workspace]] = {}
    for monitor in monitors:
        monitor_id = monitor["monitor-id"]
        monitor_workspaces = [ w for w  in workspaces if w["monitor-id"] == monitor_id]
        # Get list of workspace names assigned to this monitor_id
        monitor_groups[monitor_id] = monitor_workspaces
    return monitor_groups

def cycle_workspace_group(move_focused: bool = False):
    monitors = get_monitors()
    workspaces = get_workspaces()
    windows = get_windows()

    workspace_sequences = compose_workspace_sequences(monitors=monitors, workspaces=workspaces)
    focused_window = get_focused_window()
    focused_window_target_workspace = None

    # Raise alert if inconsistent number of workspaces accross screens
    try:
        amount_of_workpaces_in_monitor = len([w for w in workspaces if w["monitor-id"] == 1])
        assert all((len(seq) == amount_of_workpaces_in_monitor for seq in workspace_sequences.values()))
    except (IndexError, KeyError, StopIteration, AssertionError) as e:
        run(["terminal-notifier", "-title", "Ctrl+Tab", "-message", f"Control+Tab failed as the workspaces are poorly set. Error: {type(e).__name__}."])
        exit(1)

    # Detect what is the current workspace index in the currently focused window.
    monitor_1_visible_workspace = next(w for w in workspaces if w["monitor-id"] == 1 and w["workspace-is-visible"])["workspace"]
    monitor_1_workspace_sequence = [w["workspace"] for w in workspace_sequences[1]]
    index_in_monitor_1 = monitor_1_workspace_sequence.index(monitor_1_visible_workspace)

    if index_in_monitor_1 == amount_of_workpaces_in_monitor - 1:
        next_workspace_index = 0
    else:
        next_workspace_index = index_in_monitor_1 + 1

    for monitor in monitors:
        monitor_id = monitor["monitor-id"]
        workspace_sequence = [w["workspace"] for w in workspace_sequences[monitor["monitor-id"]] if w["monitor-id"] == monitor_id]
        print(f"Handling monitor {monitor} with workspace sequence {workspace_sequence}")

        next_workspace = workspace_sequence[next_workspace_index]
        run(["aerospace", "workspace", next_workspace])

        if move_focused and focused_window and focused_window["monitor-id"] == monitor_id:
            focused_window_target_workspace = next_workspace
    
    if focused_window_target_workspace is not None:
        run(["aerospace", "move-node-to-workspace", "--focus-follows-window", "--window-id", str(focused_window["window-id"]), focused_window_target_workspace])


if __name__ == "__main__":

    move_focused = (len(sys.argv) > 1 and sys.argv[1] == "--move-focused")
    try:    
        cycle_workspace_group(move_focused=move_focused)
    except Exception as e:
        run(["terminal-notifier", "-title", "Ctrl+Tab", "-message", f"Control+Tab failed. Error: {(str(e))} (type: {type(e).__name__})."])
