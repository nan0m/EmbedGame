#include "register_types.h"

#include "embed_game.h"

#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/classes/editor_plugin.hpp>

using namespace godot;

void initialize_example_module(ModuleInitializationLevel p_level) {
	if (p_level == MODULE_INITIALIZATION_LEVEL_EDITOR) {
		ClassDB::register_class<EmbedGame>();
		// EditorPlugins::add_by_type<EmbedGame>();
	}
// #ifdef TOOLS_ENABLED
// 	if (p_level == MODULE_INITIALIZATION_LEVEL_EDITOR) {

// 	GDREGISTER_CLASS(EmbedGame);

	// EditorPlugins::add_by_type<EmbedGame>();
}

void uninitialize_example_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_EDITOR) {
		return;
	}
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT embed_game_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_example_module);
	init_obj.register_terminator(uninitialize_example_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_EDITOR);

	return init_obj.init();
}
}

