Shader "Unlit/01"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "Unitycg.cginc"

			struct v2f
			{
				float4 pos:POSITION;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;

			}

			fixed4 frag(v2f IN):COLOR
			{
//				fx r = 1;
//				fx g = 0;
//				fx b = 0;
//				fx a = 1;
//
//				fx2 fl2 = fx2(1,0);
//				fx3 fl3 = fx3(0,0,1);
//
//				//使用了typedef
//				fx4 fl4 = FX4_INSTALL;
//
//				col = fx4(r,g,b,a);
//
//				bool bl = false;
//
//				//三目表达式同C语言
//				col = bl?col:fx4(0,1,0,1);
//
//				//swizze操作(xyzw形式)
//				col = fx4(fl2.xy,0,1);
//				col = fx4(fl2.yx,0,1);
//
//				//swizze操作(rgba形式)
//				col = fx4(fl3.rgb,1);
//				//swizze可以随意更改分量的顺序
//				col = fx4(fl3.bgr,1);
//
//				//矩阵的使用
//				float2x2 M2x2 = {1,1,0,1};
//
//				col = fx4(M2x2[0],0,1);
//
//				float2x4 M2x4 = {{1,1,1,1},{0,1,1,1}};
//
//				col = M2x4[1];
//
//				//struct的使用
//				v2f o;
//
//				o.pos = M2x4[0];
//
//				o.uv = M2x4[1];
//
//				//数组的使用,同C语言
//				float array[4] = {0,0,0,1};

				return fixed4(1,1,1,1);
			}
			ENDCG
		}
	}
}
