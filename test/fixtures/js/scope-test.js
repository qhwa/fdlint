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
         //tempӦ��Ҫ����ȷ�ؼ��Ϊȫ�ֱ��� 
         temp = [a,b,c];

         // $ �ڸ��ռ��ж��壬����ȫ�ֱ���
         $ = jQuery;

         // temp3 ���·����壬����ȫ�ֱ���
         temp3 = "foo";
         var temp3;

         // temp4 �Ǻ�������������ȫ�ֱ���
         temp4 = "bar";

         return new Node(temp).appendTo(menuEl);

		 test = 123;

		//var temp2;
		temp2 = 234;
      };

    $.data;

})(jQuery);
