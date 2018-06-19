// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/DiffuseLight"
{
	SubShader
	{
		//漫反射shader一定要有这个(ForwardBase是指定顶点受光(包括环境光,方向光,光照贴图等,如果没有这个tag效果会错误))
		tags{"LightMode"="ForwardBase"}
		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#include "lighting.cginc"
		
			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//取得法向量并单位化
				float3 N = normalize(v.normal);

				//点积的两个向量一定要在同一个坐标系当中
				//方案1
				//将法向量变换到世界空间坐标(因为_WorldSpaceLightPos0是在世界空间坐标中,如果不转换会表现错误)
				//N = mul(unity_ObjectToWorld,float4(N,0)).xyz;

				float3 L = normalize(_WorldSpaceLightPos0).xyz;

				//方案2
				//将光向量转换到模型空间坐标系当中并单位化
				//float4 L = normalize(mul(_World2Object,_WorldSpaceLightPos0));

				//无论是方案1还是方案2还有个问题,当模型非等比缩放时还是会出现表现错误
				//因为法向量和世界变换矩阵相乘后并不能完美的表达是世界坐标系的法向量,当模型非等比缩放时法向量也会跟着缩放,这样就不再垂直于模型顶点了
				//正确的做法是让法向量和世界矩阵的逆的转置矩阵相乘
				//mul中的两个参数互换即使乘以转置矩阵,世界矩阵的逆矩阵就是模型矩阵unity_WorldToObject
				N = mul(float4(N,0),unity_WorldToObject).xyz;

				float Dot = saturate(dot(N,L));

				o.col = _LightColor0 * Dot;

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return IN.col + UNITY_LIGHTMODEL_AMBIENT;
			}
			ENDCG
		}
	}
}
