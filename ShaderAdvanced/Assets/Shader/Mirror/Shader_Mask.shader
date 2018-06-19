Shader "Unlit/Shader_Mask"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	//这是一个裁切Shader(当物体处于镜面上时,镜面以上的部分显示出来,以下的部分被裁剪掉)
	SubShader
	{
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		Pass
		{
			blend srcalpha oneminussrcalpha

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
				float4 worldPos: TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//o为世界坐标系中镜面的某一点的坐标
			float3 _o;
			//n为镜面的法线
			float3 _n;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				float3 N = normalize(_n);

				//计算镜面上的点到该物体某一点的向量
				float3 op = normalize(i.worldPos - _o);

				//计算镜面法向量和op的点积,如果为正,则表示在镜子的另外一边,反之在这一边
				float value = dot(op,N);

				//如果在镜子的另外一边就剔除
				if(value > 0)
					col.a = 0;

				return col;
			}
			ENDCG
		}
	}
}
