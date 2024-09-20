#ifndef EMBED_WINDOW_H
#define EMBED_WINDOW_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/editor_plugin.hpp>

namespace godot {

class EmbedWindow : public RefCounted {
	GDCLASS(EmbedWindow, RefCounted)

private:
	uint32_t stored_style;
	uint32_t stored_ex_style;

protected:
	static void _bind_methods();

public:
	EmbedWindow();
	~EmbedWindow();

	void set_window_borderless(int);
    int get_hwnd_by_title(String );
    void set_window_rect(int hwnd, Rect2i rect);
    void make_child(int parent_window_hwnd, int child_window_hwnd );
	void store_window_style(int hwnd_int);
	void revert_window_style(int hwnd_int);
	void unmake_child(int child_window_hwnd);
};

}

#endif