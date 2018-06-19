Shader "Unlit/04"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "unitycg.cginc"

			//从脚步中获取
			uniform float4x4 mvp;

			float4x4 rm;

			float4x4 sm;

			struct v2f
			{
				float4 pos:POSITION;
			};

			v2f vert(appdata_base v)
			{
				v2f o;

				//mvp矩阵和旋转矩阵先乘
				float4x4 m = mul(UNITY_MATRIX_MVP,rm);

				//mvp矩阵和缩放矩阵先乘
				float4x4 rs = mul(m,sm);

				o.pos = mul(rs,v.vertex);

				//使用自定义矩阵
				//o.pos = mul(mvp,v.vertex);

				return o;
			}

			fixed4 frag():COLOR
			{
				return fixed4(1,1,1,1);
			}
			ENDCG
		}
	}
}
