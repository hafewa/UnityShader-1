Shader "test/Test_Water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_A("A",range(0,1)) = 0.01
		_L("L",range(0,5)) = 0.5
		_S("S",range(0,20)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		grabpass{}
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
				float3 N:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GrabTexture;
			float _A,_L,_S;
			
			v2f vert (appdata v)
			{
				float w = 2*3.1415926/_L;
				float f = _S*w;
				v.vertex.y+=_A*sin(length(v.vertex.xz*w)+_Time.y*f);
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float dx = w*v.vertex.x*cos(length(v.vertex.xz*w)+_Time.y*f);
				float dy = w*v.vertex.z*cos(length(v.vertex.xz*w)+_Time.y*f);

				float3 dao_x = float3(1,dx,0);
				float3 dao_z = float3(0,dx,1);

				o.N = cross(dao_x,dao_z);

				o.proj = ComputeGrabScreenPos(o.vertex );
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float detal = dot(i.N,float3(0,1,0));

				i.proj+=detal;
				fixed4 col = tex2Dproj(_GrabTexture, i.proj);

				return col*0.5;
			}
			ENDCG
		}
	}
}
