$LOC = File.join(['']) if $LOC.nil?

require 'rubygems'

require 'tsort'
require 'pp'
require 'set'
require 'ruby2ruby'
require 'ruby_parser'
require 'logger'
require 'singleton'
require 'yaml'
require 'fileutils'

require $LOC+File.join(['ruby_code','Object'])
require $LOC+File.join(['ruby_code','String'])
require $LOC+File.join(['ruby_code','Fixnum'])
require $LOC+File.join(['ruby_code','Array'])
require $LOC+File.join(['ruby_code','NilClass'])
require $LOC+File.join(['ruby_code','Hash'])
require $LOC+File.join(['ruby_code','Symbol'])

require $LOC+File.join(['core','kernal','LocalVariablesCall'])
require $LOC+File.join(['core','kernal','EvalCall'])

require $LOC+File.join(['core','runtime_method','ParametersContainer'])
require $LOC+File.join(['core','runtime_method','WriteParameters'])
require $LOC+File.join(['core','runtime_method','ActsAsRuntimeMethod'])

require $LOC+File.join(['core','declaration','Declaration'])
require $LOC+File.join(['core','declaration','LiteralDeclaration'])
require $LOC+File.join(['core','declaration','VariableDeclaration'])

require $LOC+File.join(['core','variable','VariableIncluded'])

require $LOC+File.join(['core','tracking','ActsAsTrackable'])
require $LOC+File.join(['core','tracking','Step'])

require $LOC+File.join(['core','TheoryGenerator'])
require $LOC+File.join(['core','Token'])
require $LOC+File.join(['core','CTestCase'])
require $LOC+File.join(['core','BlockToken'])
require $LOC+File.join(['core','ActsAsCode'])
require $LOC+File.join(['core','PrintVariables'])
require $LOC+File.join(['core','Container'])
require $LOC+File.join(['core','statement','ActsAsStatement'])
require $LOC+File.join(['core','statement','Statement'])
require $LOC+File.join(['core','tracking','History'])
require $LOC+File.join(['core','statement','StatementGroup'])
require $LOC+File.join(['core','runtime_method','RuntimeMethod'])
require $LOC+File.join(['core','runtime_method','RealisedRuntimeMethod'])
require $LOC+File.join(['core','tracking','RuntimeTrackingMethod'])
require $LOC+File.join(['core','syntax','Code'])
require $LOC+File.join(['core','MethodUsage'])
require $LOC+File.join(['core','call_container','CallContainer'])
require $LOC+File.join(['core','InstanceCallContainer'])

require $LOC+File.join(['core','assignment','Assignment'])
require $LOC+File.join(['core','assignment','Equivalent'])
require $LOC+File.join(['core','assignment','Equal'])
require $LOC+File.join(['core','assignment','NotEqual'])

require $LOC+File.join(['core','class_method_call','RuntimeClassMethodCall'])
require $LOC+File.join(['core','class_method_call','New'])

require $LOC+File.join(['core','instance_call','InstanceCall'])
require $LOC+File.join(['core','instance_call','Times'])
require $LOC+File.join(['core','instance_call','Push'])
require $LOC+File.join(['core','instance_call','ArrayEach'])
require $LOC+File.join(['core','instance_call','DeclaredVariable'])
require $LOC+File.join(['core','instance_call','ArrayLength'])
require $LOC+File.join(['core','instance_call','Chop'])
require $LOC+File.join(['core','instance_call','Copy'])
require $LOC+File.join(['core','instance_call','StringLength'])
require $LOC+File.join(['core','instance_call','Params'])
require $LOC+File.join(['core','instance_call','length_equal'])
require $LOC+File.join(['core','instance_call','instance_calls'])

require $LOC+File.join(['core','method_call','ClassCall'])
require $LOC+File.join(['core','method_call','DefCall'])
require $LOC+File.join(['core','method_call','AvailableVariablesCall'])
require $LOC+File.join(['core','method_call','ToDeclarationCall'])
require $LOC+File.join(['core','method_call','MethodNameCall'])
require $LOC+File.join(['core','method_call','EvaluateClassCall'])

require $LOC+File.join(['error','IncompatiableRequirementsError'])
require $LOC+File.join(['error','FailedToFindStatementError'])
require $LOC+File.join(['error','FailedToFindStatementContainerError'])
require $LOC+File.join(['error','RuntimeSyntaxError'])
require $LOC+File.join(['error','MethodSizeError'])
require $LOC+File.join(['error','FailedToFindVariableError'])
require $LOC+File.join(['error','UnknownStatementType'])
require $LOC+File.join(['error','FailedVariableMatch'])
require $LOC+File.join(['error','FailedToLiteraliseError'])
require $LOC+File.join(['error','UnexpectedStatementTypeError'])
require $LOC+File.join(['error','UnliteralisableError'])
require $LOC+File.join(['error','InvalidStatementError'])
require $LOC+File.join(['error','ImproperStatementUsageError'])

require $LOC+File.join(['core','requirement','Requirement'])

require $LOC+File.join(['core','statement','HackStatement'])
require $LOC+File.join(['core','statement','DeclarationStatement'])
require $LOC+File.join(['core','statement','OpenStatement'])
require $LOC+File.join(['core','statement','ArrayAccess'])
require $LOC+File.join(['core','statement','HashAccess'])
require $LOC+File.join(['core','statement','TopologicalStatements'])
require $LOC+File.join(['core','statement','TheoryStatement'])

require $LOC+File.join(['MappingValues'])
require $LOC+File.join(['Mapping'])

require $LOC+File.join(['core','statement','BlockStatement'])
require $LOC+File.join(['core','statement','SingleLineBlockStatement'])

require $LOC+File.join(['core','literal','Literal'])
require $LOC+File.join(['core','literal','Raw'])
require $LOC+File.join(['core','literal','RuntimeMethodLiteral'])
require $LOC+File.join(['core','literal','StatementLiteral'])

require $LOC+File.join(['core','runtime_class','ClassName'])
require $LOC+File.join(['core','runtime_class','ClassCallClass'])
require $LOC+File.join(['core','runtime_class','ClassEvaluationClass'])
require $LOC+File.join(['core','runtime_class','RequirementClass'])
require $LOC+File.join(['core','runtime_class','InstanceCallClass'])
require $LOC+File.join(['core','runtime_class','ThisClass'])
require $LOC+File.join(['core','runtime_class','StringClass'])
require $LOC+File.join(['core','runtime_class','FixnumClass'])
require $LOC+File.join(['core','runtime_class','RuntimeMethodClass'])
require $LOC+File.join(['core','runtime_class','MethodUsageClass'])
require $LOC+File.join(['core','runtime_class','UnknownClass'])
require $LOC+File.join(['core','runtime_class','StatementClass'])
require $LOC+File.join(['core','runtime_class','ReturnClass'])
require $LOC+File.join(['core','runtime_class','RuntimeClassClass'])
require $LOC+File.join(['core','runtime_class','DefCallClass'])
require $LOC+File.join(['core','runtime_class','MethodParameterClass'])
require $LOC+File.join(['core','runtime_class','EqualClass'])
require $LOC+File.join(['core','runtime_class','LiteralClass'])
require $LOC+File.join(['core','runtime_class','RuntimeClass'])
require $LOC+File.join(['core','runtime_class','ArrayClass'])
require $LOC+File.join(['core','runtime_class','StringLengthClass'])
require $LOC+File.join(['core','runtime_class','StringVariableClass'])
require $LOC+File.join(['core','runtime_class','InstanceCallContainerClass'])
require $LOC+File.join(['core','runtime_class','runtime_class'])
require $LOC+File.join(['core','runtime_class','class_names'])

require $LOC+File.join(['core','variable','Variable'])
require $LOC+File.join(['core','variable','BaseVariable'])
require $LOC+File.join(['core','variable','BlockVariable'])
require $LOC+File.join(['core','variable','VariableContainer'])
require $LOC+File.join(['core','variable','MethodUsageVariable'])
require $LOC+File.join(['core','variable','TypeVariable'])
require $LOC+File.join(['core','variable','RuntimeMethodParameter'])
require $LOC+File.join(['core','variable','StatementVariable'])
require $LOC+File.join(['core','variable','MethodParameter'])
require $LOC+File.join(['core','variable','Unknown'])
require $LOC+File.join(['core','variable','FixnumVariable'])
require $LOC+File.join(['core','variable','StringVariable'])
require $LOC+File.join(['core','variable','StepVariable'])
require $LOC+File.join(['core','variable','ArrayVariable'])
require $LOC+File.join(['core','variable','NilVariable'])
require $LOC+File.join(['core','variable','VariableReference'])
require $LOC+File.join(['core','variable','UnknownVariable'])

require $LOC+File.join(['core','syntax','Return'])
require $LOC+File.join(['core','syntax','syntax'])
require $LOC+File.join(['core','syntax','Boolean'])
require $LOC+File.join(['core','syntax','True'])
require $LOC+File.join(['core','syntax','False'])
require $LOC+File.join(['core','syntax','Subtract'])
require $LOC+File.join(['core','syntax','Nil'])
require $LOC+File.join(['core','syntax','Addition'])
require $LOC+File.join(['core','syntax','Do'])
require $LOC+File.join(['core','syntax','If'])
require $LOC+File.join(['core','syntax','BlockContainer'])
require $LOC+File.join(['core','syntax','This'])

require $LOC+File.join(['theory','TheoryVariable'])
require $LOC+File.join(['theory','TheoryComponent'])
require $LOC+File.join(['theory','TheoryDependent'])
require $LOC+File.join(['theory','TheoryAction'])
require $LOC+File.join(['theory','TheoryResult'])
require $LOC+File.join(['Theory'])
require $LOC+File.join(['theory','TheoryConnector'])
require $LOC+File.join(['theory','TheoryChainValidator'])
require $LOC+File.join(['theory','TheoryImplementation'])
require $LOC+File.join(['theory','ActionImplementation'])
require $LOC+File.join(['theory','theory_collection'])

require $LOC+File.join(['intrinsic','IntrinsicObject'])
require $LOC+File.join(['intrinsic','IntrinsicLiteral'])
require $LOC+File.join(['intrinsic','IntrinsicRuntimeMethod'])
require $LOC+File.join(['intrinsic','IntrinsicTestCases'])
require $LOC+File.join(['intrinsic','IntrinsicLastRuntimeMethod'])

require $LOC+File.join(['logger','StandardLogger'])

require $LOC+File.join(['util','StatementCheck'])
require $LOC+File.join(['util','CodeEvaluation'])
require $LOC+File.join(['util','MethodEvaluation'])
require $LOC+File.join(['util','ClassEvaluation'])
require $LOC+File.join(['util','DeclarationStatementEvaluation'])
require $LOC+File.join(['util','System'])
require $LOC+File.join(['util','MethodTester'])
require $LOC+File.join(['util','MethodValidation'])
require $LOC+File.join(['util','Parser'])
require $LOC+File.join(['util','StringToTheory'])
require $LOC+File.join(['util','MethodWriter'])

require $LOC+File.join(['core','ClassMethodCallContainer'])

require $LOC+File.join(['CodeHandler'])
require $LOC+File.join('Chain')
require $LOC+File.join('UnifiedChain')
require $LOC+File.join('PartialChain')
require $LOC+File.join('implemented_chain')
require $LOC+File.join('ChainMapping')

# TEST HELPERS
require $LOC+File.join(['theories'])
require $LOC+File.join(['cauldron','util','home'])
require $LOC+File.join(['cauldron','pot'])
