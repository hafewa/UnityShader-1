Shader "复习/Y轴旋转效果"
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
			
			v2f vert (appdata v)
			{
				v2f o;

				//得到顶点随着时间变化的变量pos
				float4 pos = v.vertex * _Time.x;

				//求得顶点坐标与中心原点的距离
				float d = length(pos);

				float new_x = cos(d)*v.vertex.x + sin(d)*v.vertex.z;
				float new_z = cos(d)*v.vertex.z -  sin(d)*v.vertex.x;

				float4 newPos  = float4(new_x,v.vertex.y,new_z,v.vertex.w);

				o.vertex = mul(UNITY_MATRIX_MVP,newPos);

				o.uv = v.uv;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}
			ENDCG
		}
	}
}
