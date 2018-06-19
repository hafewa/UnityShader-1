Shader "Unlit/Shader_MirrorReflection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MirrorTex("MirrorTex",2D) = "white" {}
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
				float4 proj:TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//从C#中传进来的投影纹理
			sampler2D _MirrorTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//MVP变换后与投影矩阵相乘
				o.proj = ComputeScreenPos(o.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 col2 = tex2Dproj(_MirrorTex,i.proj);


				return lerp(col,col2,0.7);
			}
			ENDCG
		}
	}
}
