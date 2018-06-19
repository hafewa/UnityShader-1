Shader "Unlit/10"
{
	SubShader
	{

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				//float bodu = v.vertex.x * _Time.w;

				//这里用矩阵来模拟Y轴上的缩放就不行了,因为面片模型的顶点的Y分量都是0,所以跟矩阵相乘之后还是0
//				float4x4 m =
//				{
//					float4(1,0,0,0),
//					float4(0,sin(bodu)/2 + 0.5,0,0),
//					float4(0,0,1,0),
//					float4(0,0,0,1)
//				};

				//float4 new_pos = mul(m,v.vertex);

				//正弦波公式    A * sin(w*x + t)(数学中的正弦波公式,A是振幅因子,w是与周期有关的参数,w越大周期越短,x是在哪个分量上震动,t是时间因子(越大波移动的越快),w*x+t叫做相位)
				v.vertex.y+= 0.2*sin( (v.vertex.x + v.vertex.z)  + _Time.y);
				v.vertex.y+= 0.3*sin( (v.vertex.x - v.vertex.z)  + _Time.w);

				o.col = fixed4(v.vertex.y,v.vertex.y,v.vertex.y,1);

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}

			fixed4 frag(v2f IN):COLOR
			{
				return IN.col;
			}

			ENDCG
		}
	}
}
