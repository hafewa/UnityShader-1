Shader "Unlit/体积光"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",color) = (1,1,1,1)
		_ExtrusionFactor("ExtrusionFactor",Range(0,2)) = 0.2 
		_Intensity("Intensity", Range(0, 10)) = 1  
		_WorldLightPos("WorldLightPos",vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100

		blend SrcAlpha OneMinusSrcAlpha
		ZWrite off
		Cull off

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
				float distance: TEXCOORD1;
			};

			sampler2D _MainTex;
			fixed4 _Color;
			float _ExtrusionFactor;
			float _Intensity;
			float4 _WorldLightPos;
			
			v2f vert (appdata_base v)
			{
				v2f o;

				//本地光照
				float3 objLightPos = mul(unity_WorldToObject,_WorldLightPos.xyz).xyz;

				//本地顶点到本地光照的向量
				float3 objLightDir = objLightPos - v.vertex.xyz;

				float NdotL = dot(objLightDir,v.normal);

				float contrlValue = 0;

				//如果NdotL小于0说明是背光面,背光面(肚子这一面)全部都要进行法线挤压
				if(NdotL < 0 )
				contrlValue = 1;
				else
				contrlValue = 0;//受光面保持正常渲染

				//进行法线挤压
				float4 pos = v.vertex;

				pos.xyz -= objLightDir * _ExtrusionFactor * contrlValue;

				o.vertex = UnityObjectToClipPos(pos);
				o.uv = v.texcoord.xy;
				o.distance = length(objLightDir);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				//衰减
				float atten = i.distance/_WorldLightPos.w;

				return col * _Color * atten * _Intensity;
			}
			ENDCG
		}
	}
}
