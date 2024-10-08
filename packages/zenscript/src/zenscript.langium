grammar IntelliZen

entry Script:
    ( imports+=ImportDeclaration
    | functions+=FunctionDeclaration
    | expands+=ExpandFunctionDeclaration
    | classes+=ClassDeclaration
    | statements+=Statement
    )*
;

Person:
    'person' name=ID;

Greeting:
    'Hello' person=[Person:ID] '!';

interface Declaration {}

interface ImportDeclaration extends Declaration {
    ref: @NamedElement;
    alias?: string;
}

interface ClassDeclaration extends Declaration {
    name: string;
    superTypes: @ClassDeclaration[];
    members: ClassMemberDeclaration[];
}

type NamedElement = ClassDeclaration | FunctionDeclaration | ExpandFunctionDeclaration | FieldDeclaration | ValueParameter| VariableDeclaration | ForVariableDeclaration | MapEntry | ImportDeclaration;

type ClassMemberDeclaration = FunctionDeclaration | FieldDeclaration | ConstructorDeclaration;

type CallableDeclaration = FunctionDeclaration | ExpandFunctionDeclaration | ConstructorDeclaration;

interface FieldDeclaration extends Declaration {
    prefix: 'static' | 'var' | 'val';
    name: string;
    typeRef?: TypeReference;
    initializer?: Expression;
}

interface ValueParameter extends Declaration {
    varargs?: boolean;
    name: string;
    typeRef?: TypeReference;
    defaultValue?: Expression;
}

interface FunctionDeclaration extends Declaration {
    prefix?: 'static' | 'global';
    name: string;
    parameters: ValueParameter[];
    returnTypeRef?: TypeReference;
    body: Statement[];
}

interface ExpandFunctionDeclaration extends Declaration {
    typeRef: TypeReference;
    name: string;
    parameters: ValueParameter[];
    returnTypeRef?: TypeReference;
    body: Statement[];
}

interface ConstructorDeclaration extends Declaration {
    parameters: ValueParameter[];
    body: Statement[];
}

QualifiedName returns string:
    ID ('.' ID)*
;

ImportDeclaration returns ImportDeclaration:
    'import' ref=[NamedElement:QualifiedName] ('as' alias=ID)? ';'?
;

ClassDeclaration returns ClassDeclaration:
    'zenClass' name=ID
    ('extends' (superTypes+=[ClassDeclaration:QualifiedName] (',' superTypes+=[ClassDeclaration:QualifiedName])*))?
    ('{'
        members+=ClassMemberDeclaration*
    '}')?
;

ClassMemberDeclaration returns ClassMemberDeclaration:
    FunctionDeclaration | FieldDeclaration | ConstructorDeclaration;

FieldDeclaration returns FieldDeclaration:
    prefix=('static'|'var'|'val') name=ID ('as' typeRef=TypeReference)? ('=' initializer=Expression)? ';'
;

ValueParameter returns ValueParameter:
    (varargs?='...')? name=ID ('as' typeRef=TypeReference)? ('=' defaultValue=Expression)?
;

FunctionDeclaration returns FunctionDeclaration:
    prefix=('static' | 'global')? 'function' name=ID '('
        (parameters+=ValueParameter (',' parameters+=ValueParameter)*)?
    ')' ('as' returnTypeRef=TypeReference)? '{'
        (body+=Statement)*
    '}'
;

ExpandFunctionDeclaration returns ExpandFunctionDeclaration:
    '$expand' typeRef=TypeReference '$' name=ID  '('
        (parameters+=ValueParameter (',' parameters+=ValueParameter)*)?
    ')' ('as' returnTypeRef=TypeReference)? '{'
        (body+=Statement)*
    '}'
;

ConstructorDeclaration returns ConstructorDeclaration:
    'zenConstructor' '('
        (parameters+=ValueParameter (',' parameters+=ValueParameter)*)?
    ')' '{'
        (body+=Statement)*
    '}'
;

//region Statement Interface

interface Statement {}

interface IfStatement extends Statement {
    condition: Expression;
    ifBody: Statement;
    elseBody?: Statement;
}

interface WhileStatement extends Statement {
    condition: Expression;
    body: Statement;
}

interface ForStatement extends Statement {
    variables: ForVariableDeclaration[];
    iter: Expression;
    body: Statement[];
}

interface BlockStatement extends Statement {
    body: Statement[];
}

interface ReturnStatement extends Statement {
    expr?: Expression;
}

interface ExpressionStatement extends Statement {
    expr: Expression;
}

interface BreakStatement extends Statement {}

interface ContinueStatement extends Statement {}

interface VariableDeclaration extends Declaration, Statement {
    prefix: 'global' | 'static' | 'var' | 'val';
    name: string;
    typeRef?: TypeReference;
    initializer?: Expression;
}

interface ForVariableDeclaration extends Declaration {
    name: string;
}

//endregion Statement Interface

//region Statement
Statement returns Statement:
      IfStatement
    | WhileStatement
    | ForStatement
    | BlockStatement
    | ReturnStatement
    | VariableDeclaration
    | ExpressionStatement
    | BreakStatement
    | ContinueStatement
;

VariableDeclaration returns VariableDeclaration:
    prefix=('global'|'static'|'var'|'val') name=ID ('as' typeRef=TypeReference)? ('=' initializer=Expression)? ';'
;

IfStatement returns IfStatement:
    'if' condition=Expression ifBody=Statement ('else' elseBody=Statement)?
;

WhileStatement returns WhileStatement:
    'while' condition=Expression body=Statement
;

ForStatement returns ForStatement:
    'for' variables+=ForVariableDeclaration (',' variables+=ForVariableDeclaration)* 'in' iter=Expression '{'
        (body+=Statement)*
    '}'
;

ForVariableDeclaration returns ForVariableDeclaration:
    name=ID
;

BlockStatement returns BlockStatement:
    '{' (body+=Statement)* '}'
;

ReturnStatement returns ReturnStatement:
    'return' expr=Expression? ';'
;

ExpressionStatement returns ExpressionStatement:
    expr=Expression ';'
;

BreakStatement returns BreakStatement:
    {BreakStatement} 'break' ';'
;

ContinueStatement returns ContinueStatement:
    {ContinueStatement} 'continue' ';'
;
//endregion Statement


//region Expression Interface
interface Expression {}

interface PrefixExpression extends Expression {
    op: '!' | '-';
    expr: Expression;
}

interface InfixExpression extends Expression {
    left: Expression;
    op: '!=' | '%' | '&&' | '&' | '*' | '+' | '-' | '/' | '<' | '<=' | '==' | '>' | '>=' | '^' | 'has' | 'in' | '|' | '||' | '~' | '..' | 'to';
    right: Expression;
}

interface Assignment extends Expression {
    left: Expression;
    op: '=' | '+=' | '-=' | '~=' | '*=' | '/=' | '%=' | '|=' | '&=' | '^=';
    right: Expression;
}

type LiteralExpression = StringLiteral | StringTemplate | NumberLiteral | BooleanLiteral | NullLiteral | ArrayLiteral | MapLiteral;

interface ConditionalExpression extends Expression {
    first: Expression;
    second: Expression;
    third: Expression;
}

interface FunctionExpression extends Expression {
    body: Statement[];
    parameters: ValueParameter[];
    returnTypeRef?: TypeReference;
}

interface BracketExpression extends Expression {
    value: string;
}

interface ParenthesizedExpression extends Expression {
    expr: Expression;
}

interface MemberAccess extends Expression {
    receiver: Expression;
    ref: @NamedElement;
}

interface TypeCastExpression extends Expression {
    expr: Expression;
    typeRef: TypeReference;
}

interface ArrayAccess extends Expression {
    array: Expression;
    index: Expression;
}

interface CallExpression extends Expression {
    receiver: Expression;
    arguments: Expression[];
}

interface InstanceofExpression extends Expression {
    expr: Expression;
    typeRef: TypeReference;
}

interface LocalVariable extends Expression {
    ref: @NamedElement;
}

interface NumberLiteral extends Expression {
    value: string;
}

interface IntegerLiteral extends NumberLiteral {}

interface FloatingLiteral extends NumberLiteral {}

interface BooleanLiteral extends Expression {
    value: boolean;
}

interface StringLiteral extends Expression {
    value: string;
}

interface NullLiteral extends Expression {
    value: 'null';
}

interface StringTemplate extends Expression {
    content: (string | Expression)[];
}

interface ArrayLiteral extends Expression {
    values: Expression[];
}

interface MapLiteral extends Expression {
    entries: MapEntry[];
}

interface MapEntry {
    key: Expression;
    value: Expression;
}

//endregion Expression Interface

//region Expression

Expression returns Expression:
    Assignment
;

Assignment returns Expression:
    ConditionalExpression ({Assignment.left=current} op=('='|'+='|'-='|'~='|'*='|'/='|'%='|'|='|'&='|'^=') right=Assignment)?
;

ConditionalExpression returns Expression:
    OrOrExpression ({ConditionalExpression.first=current} '?' second=ConditionalExpression ':' third=ConditionalExpression)?
;

OrOrExpression returns Expression:
    AndAndExpression ({InfixExpression.left=current} op='||' right=AndAndExpression)*
;

AndAndExpression returns Expression:
    OrExpression ({InfixExpression.left=current} op='&&' right=OrExpression)*
;

OrExpression returns Expression:
    XorExpression ({InfixExpression.left=current} op='|' right=XorExpression)*
;

XorExpression returns Expression:
    AndExpression ({InfixExpression.left=current} op='^' right=AndExpression)*
;

AndExpression returns Expression:
    RelationalExpression ({InfixExpression.left=current} op='&' right=RelationalExpression)*
;

RelationalExpression returns Expression:
    AdditiveExpression ({InfixExpression.left=current} op=('=='|'!='|'<'|'<='|'>'|'>='|'in'|'has') right=AdditiveExpression)*
;

AdditiveExpression returns Expression:
    MultiplicativeExpression ({InfixExpression.left=current} op=('+'|'-'|'~') right=MultiplicativeExpression)*
;

MultiplicativeExpression returns Expression:
    PrefixExpression ({InfixExpression.left=current} op=('*'|'/'|'%') right=PrefixExpression)*
;

PrefixExpression returns Expression:
    ({PrefixExpression} op=('!'|'-') expr=PrefixExpression) | PostfixExpression
;

MemberAccessName returns string:
    ID | STRING
;

PostfixExpression returns Expression:
    PrimaryExpression (
        ({MemberAccess.receiver=current} '.' ref=[NamedElement:MemberAccessName] ) |
        ({InfixExpression.left=current} op=('to'|'..') right=Expression) |
        ({TypeCastExpression.expr=current} 'as' typeRef=TypeReference) |
        ({ArrayAccess.array=current} '[' index=Expression ']') |
        ({CallExpression.receiver=current} '(' (arguments+=Expression (',' arguments+=Expression)* ','?)? ')') |
        ({InstanceofExpression.expr=current} 'instanceof' typeRef=TypeReference)
    )?
;

fragment PrimaryExpression returns Expression:
    ParenthesizedExpression | FunctionExpression | LocalVariable | LiteralExpression | BracketExpression
;

BracketExpression returns BracketExpression:
    '<' value=(ID | ':')+ '>'
;

ParenthesizedExpression returns ParenthesizedExpression:
    '(' expr=Expression ')'
;

LiteralExpression returns LiteralExpression:
    StringLiteral | StringTemplate | NumberLiteral | BooleanLiteral | ArrayLiteral | MapLiteral | NullLiteral
;

FunctionExpression returns FunctionExpression:
    'function' '('
        (parameters+=ValueParameter (',' parameters+=ValueParameter)*)?
    ')' ('as' returnTypeRef=TypeReference)? '{'
        (body+=Statement)*
    '}'
;

ArrayLiteral returns ArrayLiteral:
    '[' (values+=Expression (',' values+=Expression)* ','?)? ']'
;

MapLiteral returns MapLiteral:
    '{' (entries+=MapEntry (',' entries+=MapEntry)* ','?)? '}'
;

MapEntry returns MapEntry:
    key=Expression ':' value=Expression
;

LocalVariable returns LocalVariable:
    ref=[VariableDeclaration:ID]
;

NumberLiteral returns NumberLiteral:
    IntegerLiteral | FloatingLiteral
;

IntegerLiteral returns IntegerLiteral:
    value=INTEGER
;

FloatingLiteral returns FloatingLiteral:
    value=FLOATING
;

BooleanLiteral returns BooleanLiteral:
    value?='true' | 'false'
;

StringLiteral returns StringLiteral:
    value=STRING
;

NullLiteral returns NullLiteral:
    value='null'
;

StringTemplate returns StringTemplate:
    // Either just the full content
    content+=TEMPLATE_LITERAL_FULL |
    // Or template literal parts with expressions in between
    (
        content+=TEMPLATE_LITERAL_START 
        content+=Expression?
        (
            content+=TEMPLATE_LITERAL_MIDDLE
            content+=Expression?
        )*
        content+=TEMPLATE_LITERAL_END
    )
;

terminal TEMPLATE_LITERAL_FULL:
    '`' IN_TEMPLATE_LITERAL* '`';

terminal TEMPLATE_LITERAL_START:
    '`' IN_TEMPLATE_LITERAL* '${';

terminal TEMPLATE_LITERAL_MIDDLE:
    '}' IN_TEMPLATE_LITERAL* '${';

terminal TEMPLATE_LITERAL_END:
    '}' IN_TEMPLATE_LITERAL* '`';

terminal fragment IN_TEMPLATE_LITERAL:
    /[^$`\\]|\\./;

//endregion Expression


//region TypeReference Types

interface TypeReference {}

interface UnionType extends TypeReference {
    values: TypeReference[];
}

interface IntersectionType extends TypeReference {
    values: TypeReference[];
}

interface PrimitiveType extends TypeReference {
    value: 'any' | 'byte' | 'short' | 'int' | 'long' | 'float' | 'double' | 'bool' | 'void' | 'string';
}

interface ListType extends TypeReference {
    value: TypeReference;
}

interface FunctionType extends TypeReference {
    params: TypeReference[];
    returnType: TypeReference;
}

interface ClassType extends TypeReference {
    ref: @ClassDeclaration;
}

interface ParenthesizedType extends TypeReference {
    value: TypeReference;
}

interface ArrayType extends TypeReference {
    value: TypeReference;
}

interface MapType extends TypeReference {
    key: TypeReference;
    value: TypeReference;
}

//endregion

//region TypeReference

TypeReference returns TypeReference:
    UnionType
;

UnionType returns TypeReference:
    IntersectionType ({UnionType.values+=current} ('|' values+=IntersectionType)+)?
;

IntersectionType returns TypeReference:
    ComplexType ({IntersectionType.values+=current} ('&' values+=ComplexType)+)?
;

ComplexType returns TypeReference:
    PrimaryType ('['(
        ({MapType.value=current} key=TypeReference) |
        ({ArrayType.value=current})
    )']')*
;

fragment PrimaryType returns TypeReference:
    PrimitiveType | ListType | FunctionType | ParenthesizedType | ClassType
;

ParenthesizedType returns ParenthesizedType:
    '(' value=TypeReference ')'
;

PrimitiveType returns PrimitiveType:
    value=('any'| 'byte'| 'short'| 'int'| 'long'| 'float'| 'double'| 'bool'| 'void'| 'string')
;

ListType returns ListType:
    '[' value=TypeReference ']'
;

FunctionType returns FunctionType:
    'function' '('
        (params+=TypeReference (',' params+=TypeReference)*)?
    ')' returnType=TypeReference
;

ClassType returns ClassType:
    ref=[ClassDeclaration:QualifiedName]
;

//endregion TypeReference


// Soft keywords
ID returns string
    : IDENTIFIER
    | 'in'
    | 'extends'  // dzs
    | 'operator' // dzs
    | 'for_in'   // dzs
    | 'orderly'  // zenutils
;

hidden terminal WHITE_SPACE: /\s+/;
terminal IDENTIFIER: /[_a-zA-Z][\w_]*/;
terminal FLOATING: /[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?[fFdD]?/;
terminal INTEGER: /(0[xX][0-9a-fA-F]+|[0-9]+)[lL]?/;
terminal STRING: /"(\\.|[^"\\])*"|'(\\.|[^'\\])*'/;

hidden terminal BLOCK_COMMENT: /\/\*.*?\*\//;
hidden terminal LINE_COMMENT: /\/\/[^\n\r]*/;
hidden terminal PREPROCESSOR: /#[^\n\r]*/;
