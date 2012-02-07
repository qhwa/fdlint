/**
 * scope test fixture
 */
(function($){
    function test(){
        var temp;
    }

    var _createSeperator = function(){
         var _self = this,
            menuEl = _self.get('menuEl');
         //Temp应该要被正确地检测为全局变量 
         temp = [a,b,c];
         return new Node(temp).appendTo(menuEl);

		 test = 123;

		//var temp2;
		temp2 = 234;
      };

})(jQuery);
