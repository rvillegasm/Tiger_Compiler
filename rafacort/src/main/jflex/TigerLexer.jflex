package co.edu.eafit.dis.st0270.s20181.rafacort;

import java_cup.runtime.Symbol;
import java.util.Stack;

%%
%cup
%unicode
%class TigerLexer
%line
%column
/* scanner constructor */
%{

  StringBuffer string = new StringBuffer();
  /* Comment stack */
  Stack<Character> commentPile = new Stack<Character>();
  /* gets the current Token line */
  public int getLine() {
    return yyline + 1;
  }
  /* gets the current Token column */
  public int getColumn() {
    return yycolumn + 1;
  }
  public String getText() {
    return yytext();
  }

%}

number = 0 | [1-9][0-9]*
whitespace = [ \t]
eol = \n\r|\r\n|\r|\n
//comment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
commentStart = "/*"
commentContent = [^"/*""*/"] | ["*"]* | ["/"]*
commentEnd = "*/"
identifier = [:jletter:][:jletterdigit:]*["_"]* | "_main"


%state STRING
%state COMMENT

%%

<YYINITIAL> {
  /* keywords */
 
  "array"     { return new Symbol(TigerSymbols.ARRAY);    }
  "if"        { return new Symbol(TigerSymbols.IF);       }
  "then"      { return new Symbol(TigerSymbols.THEN);     }
  "else"      { return new Symbol(TigerSymbols.ELSE);     }
  "while"     { return new Symbol(TigerSymbols.WHILE);    }
  "for"       { return new Symbol(TigerSymbols.FOR);      }
  "to"        { return new Symbol(TigerSymbols.TO);       }
  "do"        { return new Symbol(TigerSymbols.DO);       }
  "let"       { return new Symbol(TigerSymbols.LET);      }
  "in"        { return new Symbol(TigerSymbols.IN);       }
  "end"       { return new Symbol(TigerSymbols.END);      }
  "of"        { return new Symbol(TigerSymbols.OF);       }
  "break"     { return new Symbol(TigerSymbols.BREAK);    }
  "nil"       { return new Symbol(TigerSymbols.NIL);      }
  "function"  { return new Symbol(TigerSymbols.FUNCTION); }
  "var"       { return new Symbol(TigerSymbols.VAR);      }
  "type"      { return new Symbol(TigerSymbols.TYPE);     }
  "import"    { return new Symbol(TigerSymbols.IMPORT);   }
  "primitive" { return new Symbol(TigerSymbols.PRIMITIVE);}
  "class"     { return new Symbol(TigerSymbols.CLASS);    }
  "extends"   { return new Symbol(TigerSymbols.EXTENDS);  }
  "method"    { return new Symbol(TigerSymbols.METHOD);   }
  "new"       { return new Symbol(TigerSymbols.NEW);      }

  /* Symbols */
  
  ","         { return new Symbol(TigerSymbols.COMMA);    }
  ":"         { return new Symbol(TigerSymbols.COLON);    }
  ";"         { return new Symbol(TigerSymbols.SEMICOLON);}
  "("         { return new Symbol(TigerSymbols.LPAREN);   }
  ")"         { return new Symbol(TigerSymbols.RPAREN);   }
  "["         { return new Symbol(TigerSymbols.LCOR);     }
  "]"         { return new Symbol(TigerSymbols.RCOR);     }
  "{"         { return new Symbol(TigerSymbols.LKEY);     }
  "}"         { return new Symbol(TigerSymbols.RKEY);     }
  "."         { return new Symbol(TigerSymbols.POINT);    }
  "+"         { return new Symbol(TigerSymbols.ADD);      }
  "-"         { return new Symbol(TigerSymbols.SUB);      }
  "*"         { return new Symbol(TigerSymbols.TIMES);    }
  "/"         { return new Symbol(TigerSymbols.DIV);      }
  "="         { return new Symbol(TigerSymbols.EQUALS);   }
  "<>"        { return new Symbol(TigerSymbols.DIFFERENT);}
  "<"         { return new Symbol(TigerSymbols.LESSTHAN); }
  "<="        { return new Symbol(TigerSymbols.LESSEQUAL);}
  ">"         { return new Symbol(TigerSymbols.MORETHAN); }
  ">="        { return new Symbol(TigerSymbols.MOREEQUAL);}
  "&"         { return new Symbol(TigerSymbols.AND);      }
  "|"         { return new Symbol(TigerSymbols.OR);       }
  ":="        { return new Symbol(TigerSymbols.PRODUCE);  }

  /* comments */
  {commentStart} { yybegin(COMMENT); commentPile.push('c'); }

  //{comment}    {/* ignore */} THIS IS NOT USED ANYMORE

  /* whitespace */

  {whitespace} {/* ignore */}

  /* eol */

  {eol}        {/* ignore */}

  /* Identifiers */

  {identifier} { return new Symbol(TigerSymbols.ID); }

  /* Integer */
  {number}     { return new Symbol(TigerSymbols.INTEGER, new Integer(yytext()));  }

  /* Start of a string */

  \"           { string.setLength(0); yybegin(STRING); } 
}

<COMMENT> {
  {commentStart}   { commentPile.push('c'); }
  {commentContent} { }
  {commentEnd}     { 
                      if(commentPile.peek().equals('c')) {
                        commentPile.pop();
                      }
                      if(commentPile.isEmpty()) {
                        yybegin(YYINITIAL); 
                      } 
                    }
}

<STRING> {
  \"           { yybegin(YYINITIAL); return new Symbol(TigerSymbols.STRING, string.toString()); }

  [^\n\r\"\\]+ { string.append( yytext() ); }

  \\a          { string.append("\\a"); }
  \\b          { string.append("\\b"); }
  \\f          { string.append("\\f"); }
  \\n          { string.append("\\n"); }
  \\r          { string.append("\\r"); }
  \\t          { string.append("\\t"); }
  \\v          { string.append("\\v"); }
  \\\          { string.append("\\");  }
  \\\"         { string.append("\\\"");}

  \\[0-7][0-7][0-7]          { string.append( yytext() ); }

  \\x[0-9a-fA-F][0-9a-fA-F]  { string.append( yytext() ); }

  \\.          { throw  new Error("Illegal escape sequence <"+ yytext() +"> at line: " + (yyline +1) + " column: " + yycolumn); }
  
}

<<EOF>>        { 
                  if(!commentPile.isEmpty()) { 
                    throw new Error("Syntax Error: Comment not closed correctly"); 
                  } 
                  else { 
                    return new Symbol(TigerSymbols.EOF);}     
                }
.              { throw  new Error("Illegal Character <"+ yytext() +"> at line: " + (yyline +1) + " column: " + yycolumn); }


