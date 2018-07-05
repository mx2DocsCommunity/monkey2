
Namespace iap

#If __MOBILE_TARGET__

#Import "<std>"
#Import "<mojo>"

#If __TARGET__="android"

#Import "iap_android"

#Elseif __TARGET__="ios"

#Import "iap_ios"

#Endif

Using std..
Using mojo..

Enum ProductType
	Consumable=1
	NonConsumable=2
End

Class IAPStore
	
	Field OpenStoreComplete:Void( result:Int,interrupted:Product[],owned:Product[] )
	
	Field BuyProductComplete:Void( result:Int,product:Product )
	
	Field GetOwnedProductsComplete:Void( result:Int,owned:Product[] )
	
	Method New()

		_iap=New IAPStoreRep
	End
	
	Property Open:Bool()
		
		Return _state>0
	End
	
	Property Busy:Bool()
		
		Return _state>1
	End
	
	Method OpenStore( products:Product[] )
		
		If _state<>0 Return
		
		_products=products

		_state=2
		
		App.Idle+=UpdateState

		If _iap.OpenStoreAsync( _products ) Return
		
		App.Idle-=UpdateState
		
		_state=0
		
		OpenStoreComplete( -1,Null,Null )
	End
	
	Method BuyProduct( product:Product )
		
		If _state<>1 Return
		
		Print "_state="+_state
		
		_buying=product
		
		_state=3
		
		App.Idle+=UpdateState
		
		If _iap.BuyProductAsync( _buying ) Return
		
		App.Idle-=UpdateState
		
		_buying=Null
		
		_state=1
		
		BuyProductComplete( -1,product )
	End
	
	Method GetOwnedProducts()
		
		If _state<>1 Return
		
		_state=4
		
		App.Idle+=UpdateState
		
		If _iap.GetOwnedProductsAsync() Return
		
		App.Idle-=UpdateState
		
		_state=1
		
		GetOwnedProductsComplete( -1,Null )
	End
	
	Method CloseStore()
		
		If _state<>1 Return
		
		_iap.CloseStore()
		
		_iap=Null
		
		_state=-1
	End
	
	Function CanMakePayments:Bool()
		
		Return IAPStoreRep.CanMakePayments()
	End
	
	Private
	
	Field _products:Product[]
	
	Field _iap:IAPStoreRep
	
	Field _state:=0
	
	Field _buying:Product

	Method UpdateState()
		
		If _iap.IsRunning() 
			App.Idle+=UpdateState
			Return
		Endif
		
		Local result:=_iap.GetResult()
		Local state:=_state
		
		_state=1
		
		Select state
		Case 2	'openstore
			
			If result<0 _state=0

			Local interrupted:=New Stack<Product>
			Local owned:=New Stack<Product>
			For Local product:=Eachin _products
				If product.Interrupted interrupted.Push( product )
				If product.Owned owned.Push( product )
			Next
			OpenStoreComplete( result,interrupted.ToArray(),owned.ToArray() )
			
		Case 3	'buyproduct
			
			Local buying:=_buying
			_buying=Null
			BuyProductComplete( result,buying )
			
		Case 4	'GetOwnedProducts
			
			Local owned:=New Stack<Product>
			For Local product:=Eachin _products
				If product.Owned owned.Push( product )
			Next
			GetOwnedProductsComplete( result,owned.ToArray() )
		End
		
	End
	
End

#Endif
