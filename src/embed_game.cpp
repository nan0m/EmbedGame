#include "embed_game.h"
#include <godot_cpp/core/class_db.hpp>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <windowsx.h>
#include <godot_cpp/variant/utility_functions.hpp>
#include <string>
#pragma comment(lib, "user32.lib")

using namespace godot;

void EmbedGame::_bind_methods() {
    ClassDB::bind_method(D_METHOD("get_hwnd_by_title", "p_title"), &EmbedGame::get_hwnd_by_title);
	ClassDB::bind_method(D_METHOD("set_window_rect", "HWND_as_int","rect"), &EmbedGame::set_window_rect);
	ClassDB::bind_method(D_METHOD("make_child", "parent_window_hwnd","child_window_hwnd"), &EmbedGame::make_child);
	ClassDB::bind_method(D_METHOD("set_window_borderless"), &EmbedGame::set_window_borderless);
	ClassDB::bind_method(D_METHOD("store_window_style"), &EmbedGame::store_window_style);
	ClassDB::bind_method(D_METHOD("revert_window_style"), &EmbedGame::revert_window_style);
	ClassDB::bind_method(D_METHOD("unmake_child", "child_hwnd"), &EmbedGame::unmake_child);
	ClassDB::bind_method(D_METHOD("store_window_placement", "hwnd"), &EmbedGame::store_window_placement);
	ClassDB::bind_method(D_METHOD("show_window", "hwnd", "flag"), &EmbedGame::show_window);
	ClassDB::bind_method(D_METHOD("embed_window", "parent_hwnd", "child_hwnd"), &EmbedGame::embed_window);



}

EmbedGame::EmbedGame() {
	// Initialize any variables here.
	// time_passed = 0.0;
	stored_style = 0;
	stored_ex_style = 0;
	stored_window_placement = {0};
	// stored_window_rect ;

}

EmbedGame::~EmbedGame() {
	// Add your cleanup here.
}

void EmbedGame::set_window_borderless(int hwnd_int) {
	HWND hwnd = (HWND)(hwnd_int);
    // Get the current window styles
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    LONG exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

	//store original styles
	// stored_style = style;
	// stored_ex_style = exStyle;

    // Remove border, title bar, and other decorations
    style &= ~(WS_BORDER | WS_DLGFRAME | WS_CAPTION | WS_THICKFRAME);
    exStyle &= ~(WS_EX_CLIENTEDGE | WS_EX_WINDOWEDGE);

    // Set the new style
    SetWindowLong(hwnd, GWL_STYLE, style);
    SetWindowLong(hwnd, GWL_EXSTYLE, exStyle);

    // Redraw the window with the new style
    SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
};
void EmbedGame::store_window_style(int hwnd_int){
	HWND hwnd = (HWND)(hwnd_int);
	EmbedGame::store_window_placement(reinterpret_cast<uintptr_t>(hwnd));

    // Get the current window styles
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    LONG exStyle = GetWindowLong(hwnd, GWL_EXSTYLE);

	// stored_window_rect=
	//store original styles
	stored_style = style;
	stored_ex_style = exStyle;

};
void EmbedGame::revert_window_style(int hwnd_int){
	HWND hwnd = (HWND)(hwnd_int);
	// Set the new style
    SetWindowLong(hwnd, GWL_STYLE, stored_style);
    SetWindowLong(hwnd, GWL_EXSTYLE, stored_ex_style);

    // Redraw the window with the 	new style
    // SetWindowPos(hwnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_FRAMECHANGED);
	SetWindowPlacement(hwnd, &stored_window_placement);
};

int EmbedGame::get_hwnd_by_title(String title){
    LPCWSTR lpc = (LPCWSTR)(title.utf16().get_data());	
	HWND hwnd  = FindWindowW(NULL, lpc);
	int hwnd_as_int = reinterpret_cast<uintptr_t>(hwnd);
	return hwnd_as_int;
};

void EmbedGame::set_window_rect(int hwnd_as_int, Rect2i rect){
	HWND hwnd = (HWND)(hwnd_as_int);
	int xPos = (rect.position.x);
	int yPos = (rect.position.y);
	int width = (rect.size.x);
	int height = (rect.size.y);
	SetWindowPos(hwnd, nullptr, xPos, yPos, width, height, SWP_NOZORDER | SWP_NOACTIVATE);

};

void EmbedGame::store_window_placement(int hwnd_int) {
	HWND hwnd = (HWND)(hwnd_int);
    WINDOWPLACEMENT win_pl = {0}; // Initialize structure
    win_pl.length = sizeof(WINDOWPLACEMENT); // Must be set before use

    if (GetWindowPlacement(hwnd, &win_pl)) {
        stored_window_placement = win_pl; // Store only if successful
    } else {
        // Handle error if needed
    }
}

void EmbedGame::make_child(int parent_window_hwnd, int child_window_hwnd){
	HWND parent_hwnd = (HWND)(parent_window_hwnd);
	HWND child_hwnd = (HWND)(child_window_hwnd);
	SetParent(child_hwnd, parent_hwnd);
};

void EmbedGame::unmake_child(int child_window_hwnd){
	HWND child_hwnd = (HWND)(child_window_hwnd);
	SetParent(child_hwnd, NULL);
	}

void EmbedGame::show_window(int hwnd_int, bool flag){
	HWND hwnd = (HWND)(hwnd_int);
	if (flag){
		ShowWindow(hwnd, SW_RESTORE);
	} else{
		ShowWindow(hwnd, SW_HIDE);
	};

}

void EmbedGame::embed_window(int parent_window_hwnd, int child_window_hwnd){
	store_window_style(child_window_hwnd);
	set_window_borderless(child_window_hwnd);
	make_child(parent_window_hwnd, child_window_hwnd);
};
