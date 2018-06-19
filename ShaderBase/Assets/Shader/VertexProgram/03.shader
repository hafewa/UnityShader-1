Shader "Unlit/03"
{
	properties 
	{
		_MainColor("Main Color",color) = (1,1,1,1)
		_LerpValue("Lerp Value",range(0,1)) = 0.5
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
			#pragma vertex vert
			#pragma fragment frag

			#include "MyCG/MyCG.cginc"

			//struct 支持别名(typedef)
			//顶点程序的输出结构
			//这个结构一般不放在cginc中引用使用,因为输出的数据并不能始终都是确定的数据类型和个数
			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
				float2 opos:TEXCOORD0;
			};

			float4 _MainColor;
			float _LerpValue;
			//uniform是从外部获取的数据,比如在C#脚步中(如果_OtherColor没有赋值,则默认为0)
			uniform float4 _OtherColor;

			//因为顶点函数有了返回值,但是返回值当中并不包含语义信息(虽然该返回值可能就是参数本身,参数本身有了语义的定义也不行,因为参数中的语义并不是输出的时候定义的),所以要在函数末尾加上语义,否则会报错
			//如果参数中含有和末尾语义相同语义的参数并且使用了out也会报错,这样的话系统就不知道输出的到底是哪个该语义的变量
			//用TEXCOORD0将系统输入的顶点信息存起来也是没有问题的,因为这样可以避免重复输出相同语义(POSITION)的变量导致报错
			v2f vert(appdata_base v)
			{
				v2f o;
				o.pos = float4(v.pos,0,1);
				//如果输入的COLOR语义的数据没有赋值,Unity引擎默认为白色
				o.col = v.col;
				o.opos = v.pos;

				return o;
			}

			//inout既传人也输出
			//从vert传进来的col,同时输出
			//POSITION语义的数据不能直接传人frag.片段程序不支持POSITION
			//封装结构体之后即使片段程序没有用结构体接收,只要接收的数据语义和结构体重的某个数据语义相同就可以正确接收
			//直接用结构体接收也可以
			fixed4 frag(v2f IN):COLOR
			{
				//直接调用这个函数是没有效果的,因为cg当中全是值拷贝,没有指针的概念,但是只要参数中加了out,就可以输出
				//Func(col);

				//这里没有指定维度是因为后面明确给出了赋值
				//float arr[] = {0.5,0.5};
				//col.z = Func2(arr);
				//col.x = pos.x;

				//这里就是接收了v2f中col的数据
				//return IN.col;

				//向量的乘法并不能起到颜色混合的效果(因为向量的某些分量可能为0,这样不管另外一个向量的分量为不为零,相乘之后还为0)
				//return _MainColor * _OtherColor;

				//向量相加才能起到混合颜色的效果(乘以0。5是因为某个向量的分量很大，两个向量相加很可能>=1,这样也不能正确显示混合的效果)
				//return _MainColor * 0.5 + _OtherColor * 0.5;

				//CG中的插值函数,效果同上(参数3就是权重)
				return lerp(_MainColor,_OtherColor,_LerpValue);
			}

			ENDCG
		}
	}
}
