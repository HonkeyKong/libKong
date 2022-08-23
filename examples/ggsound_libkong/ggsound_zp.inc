.space sound_region 1
.space sound_disable_update 1
.space sound_local_byte_0 1
.space sound_local_byte_1 1
.space sound_local_byte_2 1

.space sound_local_word_0 2
.space sound_local_word_1 2
.space sound_local_word_2 2

.space sound_param_byte_0 1
.space sound_param_byte_1 1
.space sound_param_byte_2 1

.space sound_param_word_0 2
.space sound_param_word_1 2
.space sound_param_word_2 2
.space sound_param_word_3 2

.space base_address_instruments 2
.space base_address_note_table_lo 2
.space base_address_note_table_hi 2

;ifdef FEATURE_DPCM

.space base_address_dpcm_sample_table 2
.space base_address_dpcm_note_to_sample_index 2
.space base_address_dpcm_note_to_sample_length 2
.space base_address_dpcm_note_to_loop_pitch_index 2

;endif

.space apu_data_ready 1
.space apu_square_1_old 1
.space apu_square_2_old 1

;ifdef FEATURE_DPCM

.space apu_dpcm_state 1

;endif

.space song_list_address 2
.space sfx_list_address 2
.space song_address 2
.space apu_register_sets 20

.space stream 1
.space channel 1
.space starting_read_address 2
.space callback_address 2
.space read_address 2
