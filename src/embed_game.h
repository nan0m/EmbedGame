#ifndef EMBED_GAME_H
#define EMBED_GAME_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/editor_plugin.hpp>
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <windowsx.h>
#pragma comment(lib, "user32.lib")

namespace godot {

class EmbedGame : public RefCounted {
	GDCLASS(EmbedGame, RefCounted)

private:
	uint32_t stored_style;
	uint32_t stored_ex_style;
	
protected:
	static void _bind_methods();

public:
	EmbedGame();
	~EmbedGame();
	WINDOWPLACEMENT stored_window_placement;

	void set_window_borderless(int);
    int get_hwnd_by_title(String );
    void set_window_rect(int hwnd, Rect2i rect);
    void make_child(int parent_window_hwnd, int child_window_hwnd );
	void store_window_style(int hwnd_int);
	void revert_window_style(int hwnd_int);
	void unmake_child(int child_window_hwnd);
	void store_window_placement(int hwnd_int);
	void show_window(int hwnd_int, bool flag);
	void embed_window(int parent_window_hwnd, int child_window_hwnd);
};

}

#endif