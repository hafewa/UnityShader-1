Shader "复习/深度值模糊效果"
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
				float   z:TEXCOORD1;
			};

			sampler2D _MainTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				//将深度值转换到世界坐标空间
				o.z = mul(unity_ObjectToWorld,v.vertex.z);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//UV X方向上求导数
				float ddx_x = ddx(i.z) * 2;
				//UV Y方向上求导数
				float ddx_y = ddy(i.z) * 2;
				//带有模糊效果的采样函数(模糊效果根据顶点深度值z分别在uv xy方向求导获得)
				fixed4 col = tex2D(_MainTex, i.uv,ddx_x,ddx_y);
				return col;
			}
			ENDCG
		}
	}
}
