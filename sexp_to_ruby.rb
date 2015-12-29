require 'ripper'
require 'sorcerer'
require 'pp'

# 1. ball.collect
sexp = [:program,
          [:stmts_add,
            [:stmts_new], 
            [:call, 
              [:vcall, [:@ident, 'ball']],
              :".",
              [:@ident, 'bounce' ]
            ] 
          ]
        ]

# 2. 
# ball.bounce
# ball.kick
sexp = [:program,
          [:stmts_add,
            [:stmts_add,
              [:stmts_new], 
                [:call, 
                  [:vcall, [:@ident, 'ball']],
                  :".",
                  [:@ident, 'bounce' ]
                ]             
              ],
            [:call, 
              [:vcall, [:@ident, 'ball']],
              :".",
              [:@ident, 'kick' ]
            ],        
          ] 
        ]
# e.g.
#  [:program, [:stmts_add, [:stmts_add, [:stmts_new], 'ball.bound'], 'ball.kick' ]

bounce_call = [:call, 
                [:vcall, [:@ident, 'ball']],
                :".",
                [:@ident, 'bounce' ]
              ]
kick_call =   [:call, 
                [:vcall, [:@ident, 'ball']],
                :".",
                [:@ident, 'kick' ]
              ]
throw_call =  [:call, 
                [:vcall, [:@ident, 'ball']],
                :".",
                [:@ident, 'throw' ]
              ]              

# 3. 
# ball.bounce
# ball.kick
# ball.throw
sexp =  [:program,
          [:stmts_add,
            [:stmts_add,
              [:stmts_add,
                [:stmts_new],
                bounce_call
              ],
              kick_call
            ],
            throw_call
          ]
        ]

# 4. 
method_ident = [:@ident, "test"]
params = [:paren, [:params, [[:@ident, "var0"]] ]]
# def test(var0)
#  var0.bounce
#  var1.kick
# end
sexp =  [:program,
          [:stmts_add,
            [:stmts_new],
            [:def,
              method_ident,
              params,
              [:bodystmt,
                [:stmts_add,
                  [:stmts_add,
                    [:stmts_add,
                      [:stmts_new],
                      bounce_call
                    ],
                    kick_call
                  ],
                  throw_call
                ]
              ]
            ]
          ]
        ]

# 5. 
# var0.collect do |x|
#   record(local_variable)
# end

var_collect = [:call, 
                [:vcall, [:@ident, "var0"]],
                :".",
                [:@ident, "collect"]
              ]
var0_block_var =  [:block_var,
                    [:params, [[:@ident, "x"]] ],
                    false
                  ]
method_add_arg =  [:method_add_arg,
                    [:fcall, [:@ident, "record"]],
                    [:arg_paren,
                      [:args_add_block,
                        [:args_add,
                          [:args_new],
                          [:vcall, [:@ident, "local_variable"]]
                        ]
                      ]
                    ]
                  ]

sexp =  [:program,
          [:stmts_add,
            [:stmts_new],
            [:method_add_block,
              var_collect,
              [:do_block,
                var0_block_var,
                [:stmts_add,
                  [:stmts_new],
                  method_add_arg
                ]
              ]
            ]
          ]
        ]


pp Sorcerer.source(sexp, indent: true)
puts Sorcerer.source(sexp, indent: true)


sexp = [:call, [:vcall, [:@ident, 'var0']], :".", [:@ident, "chop"]]
pp Sorcerer.source(sexp, indent: true)