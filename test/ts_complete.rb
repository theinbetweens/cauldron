$LOAD_PATH << File.expand_path('../../lib',__FILE__)

require 'cauldron'

require 'test/unit'

#require 'test/tc_suite_complete'

require 'test/unit/core/tc_literal'
require 'test/unit/core/tc_instance_call_container'

# require 'test/unit/core/syntax/tc_block_container'
# require 'test/unit/core/syntax/tc_if_container'
# require 'test/unit/core/declaration/tc_literal_declaration'

require 'test/unit/ruby_code/tc_string'
require 'test/unit/ruby_code/tc_fixnum'
require 'test/unit/ruby_code/tc_hash'
require 'test/unit/ruby_code/tc_array'

require 'test/unit/core/tc_class_method_call'
require 'test/unit/core/method_call/tc_class_call'
# require 'test/unit/core/tc_container'
# require 'test/unit/core/tc_theory_generator'
#require 'test/unit/core/tc_ctest_case'

require 'test/unit/core/statement/tc_hack_statement'
require 'test/unit/core/statement/tc_block_statement'
require 'test/unit/core/statement/tc_open_statement'
require 'test/unit/core/statement/tc_statement_replace_variable'
require 'test/unit/core/statement/tc_statement'
require 'test/unit/core/statement/tc_statement_group'
require 'test/unit/core/statement/tc_array_access'
require 'test/unit/core/statement/tc_theory_statement'

require 'test/unit/core/tracking/tc_history'
require 'test/unit/core/tracking/tc_step'

require 'test/unit/core/variable/tc_array_variable'
require 'test/unit/core/variable/tc_block_variable'
require 'test/unit/core/variable/tc_string_variable'
require 'test/unit/core/variable/tc_fixnum_variable'
require 'test/unit/core/variable/tc_runtime_method_variable'
require 'test/unit/core/variable/tc_variable_reference'
require 'test/unit/core/variable/tc_unknown'
require 'test/unit/core/variable/tc_method_parameter_variable'

require 'test/unit/variable/tc_method_usage_variable'

require 'test/unit/util/tc_method_validation'
require 'test/unit/util/tc_string_to_theory'
require 'test/unit/util/tc_parser'

require 'test/unit/theory/tc_theory_variable'
require 'test/unit/theory/tc_theory_dependent'
require 'test/unit/theory/tc_theory_action'
require 'test/unit/theory/tc_theory_result'
#require 'test/unit/theory/tc_theory_connector'
require 'test/unit/theory/tc_theory_implementation'
# require 'test/unit/theory/tc_theory_chain_validator'
require 'test/unit/theory/tc_theory_action_implementation'

require 'test/unit/tc_instance_call'
require 'test/unit/tc_method_usage'
require 'test/unit/tc_runtime_tracking_method'
require 'test/unit/tc_variable_declaration'

require 'test/tc_describe'
require 'test/tc_method'
require 'test/tc_requirement'
require 'test/unit/core/runtime_method/tc_runtime_method'
require 'test/unit/core/runtime_method/tc_realised_runtime_method'
require 'test/tc_variable'
require 'test/unit/tc_theory'
