Shader "test/Magnifier"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		//计算_GrabTexture(之前累积的屏幕像素纹理)
		grabpass{}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 proj:TEXCOORD0;
				float2 uv_offset:TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;

			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.proj = ComputeGrabScreenPos(o.vertex);

				//将法向量变换到视矩阵(仿照将法向量变换到世界空间矩阵的做法)并且和视矩阵的X轴求夹角,当夹角大于90度的时候uv向右偏移,当小于90度的时候向左偏移(这样就能实现放大镜的效果)
				o.uv_offset.x = -dot(v.normal,UNITY_MATRIX_IT_MV[0]);
				o.uv_offset.y = dot(v.normal,UNITY_MATRIX_IT_MV[1]);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{


				i.proj.xy+=i.uv_offset;

				fixed4 col = tex2Dproj(_GrabTexture, i.proj);



				return col;
			}
			ENDCG
		}
	}
}
