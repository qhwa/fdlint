/**
 * scope test fixture
 */
(function($){
    function test(){
        var temp;
    }

    var _createSeperator = function( temp4, data, time, scope ){
         var _self = this,
            menuEl = _self.get('menuEl');
         //temp应该要被正确地检测为全局变量 
         temp = [a,b,c];

         // $ 在父空间中定义，不是全局变量
         $ = jQuery;

         // temp3 在下方定义，不是全局变量
         temp3 = "foo";
         var temp3;

         // temp4 是函数参数，不是全局变量
         temp4 = "bar";

         return new Node(temp).appendTo(menuEl);

		 test = 123;

		//var temp2;
		temp2 = 234;
      };

    $.data;

})(jQuery);
