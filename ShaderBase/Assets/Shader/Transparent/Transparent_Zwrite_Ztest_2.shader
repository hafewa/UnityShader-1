Shader "Unlit/Transparent_Zwrite_Ztest_2"
{
	SubShader
	{
		tags{"queue" = "Transparent"}

		Pass
		{
			blend srcalpha oneminussrcalpha

			Zwrite off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos:POSITION;
			};
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return fixed4(0,0,1,0.5);
			}
			ENDCG
		}
	}
}
