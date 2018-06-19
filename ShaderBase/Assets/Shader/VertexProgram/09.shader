Shader "Unlit/09"
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

			//本shader是将模型中的顶点沿着x轴缩放(缩放比例为顶点到圆心的距离)
			v2f vert(appdata_base v)
			{
				v2f o;
				//float d = length(v.vertex)*_SinTime.w;

				//用z来作为缩放因子(每个顶点的z是不一样的)(使用乘法(然后去正弦)不能得到一个匀速的变化)
				//float d = v.vertex.z*_Time.y;

				//缩放矩阵(仅仅沿着X轴缩放,除以8是为了使得x缩放的范围比较小,这样显得变化没那么剧烈)
				//float4x4 m =
				//{
					//float4(sin(d)/8+0.5,0,0,0),
					//float4(0,1,0,0),
					//float4(0,0,1,0),
					//float4(0,0,0,1),
				//};


				//m = mul(UNITY_MATRIX_MVP,m);

				//使用+法是逐渐累加,然后取正弦就会得到一个匀速的变化(因为sin是正比函数)
				float d = v.vertex.z+_Time.y;

				//优化
				float new_x =  v.vertex.x * (sin(d)/8+0.5);
				v.vertex.x = new_x;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				o.col = fixed4(1,0,0,1);

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
