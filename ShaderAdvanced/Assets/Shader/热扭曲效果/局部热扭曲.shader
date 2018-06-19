Shader "Custom/局部热扭曲"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform sampler2D _NoiseTex;
			uniform float _DistortTimeFactor;
			uniform float _DistortStrength;
			uniform sampler2D _MaskTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 noiseCol = tex2D(_NoiseTex,i.uv - _Time.xy * _DistortTimeFactor);

				float2 offset = noiseCol.xy * _DistortStrength;

				fixed4 maskCol = tex2D(_MaskTex,i.uv);

				offset *= maskCol.r;

				i.uv += offset;

				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
