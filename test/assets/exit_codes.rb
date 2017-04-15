module ExitCodes
  EXIT_CODES = {
    single_param_action:                 20,
    class_single_param_action:           21,
    action_with_options:                 22,
    class_action_with_options:           23,
    action_not_runnable:                 24,
    class_action_not_runnable:           25,
    no_param_action:                     26,
    class_no_param_action:               27,
    two_params_action:                   28,
    class_two_params_action:             29,
    two_params_action_one_default:       30,
    class_two_params_action_one_default: 31,
    action_without_init:                 32,
    same_name_action:                    33,
    class_same_name_action:              34,
    same_param_name_action:              35,
    class_same_param_name_action:        36,
    say_hello:                           37
  }.freeze
end