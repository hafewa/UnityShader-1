Shader "test/Test_FresnelWater"
{
	Properties
	{
		_BumpTex ("Texture", 2D) = "white" {}
		_FresnelOffset("FresnelOffset",range(0,1)) = 0
		_Scale("Scale",range(0,1)) = 0
		_Strength("Strength",range(1,5)) =1
		_SpecCol("SpecColor",color) = (1,1,1,1)
		_WaterCol("WaterCol",color) = (1,1,1,1)
	}
	SubShader
	{
		blend srcalpha oneminussrcalpha
		Tags { "RenderType"="Opaque" "queue" = "transparent"}
		LOD 100

		grabpass{}

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
				float4 proj:TEXCOORD1;
				float3 v:TEXCOORD2;
				float3 l:TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			sampler2D _GrabTexture;
			fixed4 _SpecCol;
			fixed4 _WaterCol;

			float _FresnelOffset,_Scale,_Strength;
	
			
			v2f vert (appdata_tan v)
			{
				float3 n = normalize(v.normal);

				float3 t = normalize(v.tangent);

				float3 biNormal = normalize(cross(n,t));

				float3x3 t_matrix = float3x3(t,biNormal,n);

				float3 V = ObjSpaceViewDir(v.vertex);

				float3 L = ObjSpaceLightDir(v.vertex);

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = TRANSFORM_TEX(v.texcoord, _BumpTex);
			

				o.l = mul(t_matrix,L);

				o.v = mul(t_matrix, V );

				o.proj = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				float4 BumpTex_1 = tex2D(_BumpTex,i.uv+float2(_Time.x,0));
				float4 BumpTex_2 = tex2D(_BumpTex,i.uv+float2(0,_Time.x));

				float4 BumpTex = (BumpTex_1+BumpTex_2)/2;

				float3 N = normalize( UnpackNormal(BumpTex));

				float detal = dot(N,float3(0,1,0));

				i.proj += detal;


				fixed4 col = tex2Dproj(_GrabTexture, i.proj);
				col*= _WaterCol;

				fixed4 diffcol =saturate( dot(normalize(i.l),N) )* _LightColor0;

				float3 H = normalize((normalize(i.l)+normalize(i.v)));

				fixed4 highLightCol = pow(dot(normalize(H),normalize(N)),64)* _SpecCol;

				fixed4 LightCol = (diffcol + highLightCol);

				float fresnel = _FresnelOffset + _Scale*pow(1-dot(normalize(i.v),N),_Strength);


				return lerp(col,LightCol,fresnel);
			}
			ENDCG
		}
	}
}
