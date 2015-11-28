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

# 3. 
# ball.bounce
# ball.kick
# ball.throw
sexp =  [:program,
          [:stmts_add,
            [:stmts_add,
              [:stmts_add,
                [:stmts_new],
                #CALL ball.bounce
              ]
              #CALL ball.kick
            ]
            # CALL ball.throw
          ]
        ]

# 4. 
# def test(var0)
#  var0.bounce
#  var1.kick
# end


pp Sorcerer.source(sexp, indent: true)
puts Sorcerer.source(sexp, indent: true)