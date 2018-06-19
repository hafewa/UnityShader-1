Shader "Unlit/02"
{
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			typedef fixed4 fx4;

			//objpos是外部输入的模型(unity 规定了cube的各个定点的取值范围就是(-0.5,0.5),因为cube的原点在正中心)定点坐标,取值范围是(-0.5,0.5)
			void vert(in float2 objpos:POSITION,out float4 pos:POSITION,out fx4 col:COLOR)
			{
				pos = float4(objpos,0,1);

				col = pos;

				//这里满足if条件语句的代码块理论上来说会把所有像素都输出为红色,但是在光栅化的时候系统本身会做一个插值运算,使得输出的时候是渐变的
				//cg不支持switch case 但是支持if else
				if(pos.x < 0 && pos.y < 0)
				{
					col = fx4(1,0,0,1);
				}
				else if(pos.x < 0)
				{
					col = fx4(0,1,0,1);
				}
				else if(pos.y > 0)
				{
					col = fx4(0,0,1,1);
				}
				else
				{
					col = fx4(1,1,0,1);
				}
			}

			void frag(inout fx4 col:COLOR)
			{
				int i = 0;

				//cg中支持以下3种循环,但是循环次数不能超过1023,否则就会报错

				//cg中使用while循环
				while(i < 10)
				{
					i++;
				}

				if(i == 10)
					col = fx4(1,0,0,1);

				i = 0;

				//cg中使用do while 循环
				do
				{
					i++;
				}
				while(i < 10);

				if(i == 10)
					col = fx4(0,1,0,1);

				i = 0;

				//cg中使用for循环
				for(int i=0;i<1023;i++)
				{}

				if(i == 1023)
					col = fx4(0,0,1,1);
			}
			ENDCG
		}
	}
}
