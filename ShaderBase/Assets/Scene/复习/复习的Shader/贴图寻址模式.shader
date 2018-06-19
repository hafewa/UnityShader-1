Shader "复习/贴图寻找模式"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_U("U",Range(-0.1,0.1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float _U;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				o.uv = v.texcoord;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//测试寻址模式和过滤模式
				fixed4 col = tex2D(_MainTex, float2(_U,0.1));
				return col;
			}
			ENDCG
		}
	}
}
