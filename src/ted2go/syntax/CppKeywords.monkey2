
Namespace ted2go


Class CppKeywords Extends KeywordsPlugin
	
	Property Name:String() Override
		Return "CppKeywords"
	End
		
		
	Private
	
	Global _instance:=New CppKeywords
	
	Method New()
		Super.New()
		_types=New String[]( ".cpp",".h",".hpp",".c" )
	End
	
	Method GetInternal:String() Override
		Local s:="alignas;alignof;and;and_eq;asm;auto;bitand;bitor;bool;break;case;catch;char;char16_t;char32_t;class;compl;const;constexpr;const_cast;continue;decltype;default;delete;do;double;dynamic_cast;else;enum;explicit;export;extern;false;float;for;friend;"
		s+="goto;if;inline;int;long;mutable;namespace;new;noexcept;not;not_eq;nullptr;operator;or;or_eq;private;protected;public;register;reinterpret_cast;return;short;signed;sizeof;static;static_assert;static_cast;struct;switch;"
		s+="template;this;thread_local;throw;true;try;typedef;typeid;typename;union;unsigned;using;virtual;void;volatile;wchar_t;while;xor;xor_eq" 
		Return s
	End
		
End
