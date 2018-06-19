Shader "Test/Test_VertexCubeMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CubeMap("CubeMap",cube) = ""{}

		_HigtLightCol("HigtLightCol",color) = (1,1,1,1)

		_SpecValue("SpecValue",range(1,128)) = 50

		_LerpValue("LerpValue",range(0,1)) = 0.1
	}
	SubShader
	{
		tags{"LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 cube_uv:TEXCOORD1;
				float3 LightDir:TEXCOORD2;
				float3 ViewDir:TEXCOORD3;
				float3 N:Normal;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			samplerCUBE _CubeMap;
			float4 _MainTex_ST;
			float4 _HigtLightCol;
			float _SpecValue;
			float _LerpValue;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 world_view = WorldSpaceViewDir(v.vertex);

				world_view = -normalize(world_view);

				float3 wrold_Normal = UnityObjectToWorldNormal(v.normal);

				wrold_Normal = normalize(wrold_Normal);

				o.N = wrold_Normal;

				o.LightDir = normalize(WorldSpaceLightDir(v.vertex));

				o.cube_uv = reflect(world_view,wrold_Normal);

				o.ViewDir = -world_view;

				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed4 cubeCol = texCUBE(_CubeMap,i.cube_uv);

				float diff = saturate(dot(i.LightDir,i.N));

				col*= _LightColor0* diff;

				float3 H = normalize((i.LightDir + i.ViewDir));

				float3 SpecCol = pow(saturate(dot(H,i.N)),_SpecValue) * _HigtLightCol;

				col.rgb = lerp(col.rgb,SpecCol,_LerpValue);

				col += cubeCol;

				return col;
			}
			ENDCG
		}
	}
}
