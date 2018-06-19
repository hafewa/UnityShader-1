Shader "Unlit/Fresnel"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FresnelCol("FresnelCol",color) = (1,1,1,1)
		_FresnelOffset("FresnelOffset",range(0,1)) = 0
		_Scale("Scale",range(0,1)) = 0
		_Strength("Strength",range(1,5)) =1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 N:Normal;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 N:Normal;
				float3 L:TEXCOORD1;
				float3 V:TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _FresnelCol;
			float _FresnelOffset,_Scale,_Strength;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.N = normalize(UnityObjectToWorldNormal(v.N));
				o.L = normalize(WorldSpaceLightDir(v.vertex));
				o.V = normalize(WorldSpaceViewDir(v.vertex));
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				fixed4 col = tex2D(_MainTex, i.uv);

				float NdotL = saturate(dot(i.N,i.L));

				col.rgb *= _LightColor0*NdotL;

				//菲尼尔系数
				//近示的菲涅尔公式,菲尼尔所要表达的是当视向量与物体法线夹角越大的时候反射越大,当视向量与法向量夹角越小反射越小(如人的眼睛看水面,人眼总是能看清自己脚底下水中的事物,此时视向量与水面法向量的夹角最小,反之远处的水面就看不到水下的事物了,而是反射的阳光)
				//公式中是1+dot(N,V),那是因为公式中的V的向量是从眼睛指向物体的顶点,而我们这里的V是从物体的顶点指向眼睛,所以用减法
				float Fresnel = _FresnelOffset + _Scale*pow(1-dot(i.N,i.V),_Strength);

				//本例中_FresnelCol就是模拟反射光的颜色,col.rgb就是物体本身的漫反射光的颜色
				col.rgb = lerp(col.rgb,_FresnelCol,Fresnel);

				return col;
			}
			ENDCG
		}
	}
}
