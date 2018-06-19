// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/SpecularLight"
{

	properties
	{
		_SpecluarColor("SpecluarColor",Color) = (1,1,1,1)
		_Shinness("Shinness",range(0,64)) = 4
	}
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

			float4 _SpecluarColor;
			float _Shinness;
		
			struct v2f
			{
				float4 pos:POSITION;
				fixed4 col:COLOR;
			};

			
			v2f vert (appdata_base v)
			{
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				//取得光向量并单位化
				float3 L = normalize(WorldSpaceLightDir(v.vertex));

				//取得世界坐标系的法向量并单位化(方法中已经单位化)
				float3 N = UnityObjectToWorldNormal(v.vertex.xyz);

				//取得视向量并单位化
				float3 V = normalize(WorldSpaceViewDir(v.vertex));

				//============================================================================================

				//===============================
				//环境光赋值
				o.col = UNITY_LIGHTMODEL_AMBIENT;

				//漫反射
				float Dot = saturate(dot(N,L));
				o.col += _LightColor0 * Dot;

				//这一部分就是Lambert光照模型,环境光+漫反射
				//==============================


				//==================================================
				//获得指向顶点的光向量(就是光向量取反)
				//float3 I = -WorldSpaceLightDir(v.vertex);

				//根据CG函数reflect来获得顶点的反射向量
				//float3 R = reflect(I,N);

				//推倒reflect(L+R得到的向量假定为S,而S向量长度的一半正好是L的长度乘以L和N夹角(d)的余弦值,因为L和N都是单位向量,所以L和N的长度都是1,所以S向量的长度为2*cos(d),cos(d)又是dot(N,L),然后再乘以向量N(N和S向量方向相同)既可以得到向量S)
				//float3 R = 2*dot(N,L)*N-L;

				//将反射向量单位化
				//R = normalize(R);

				//获得specular(镜面反射和漫反射不同,镜面反射当视向量和光的反射向量重叠时的镜面强度最强,当有一点偏差时镜面强度迅速衰减)
				//使用pow函数即可表达迅速衰减的这种规则
				//float specularValue = pow(saturate(dot(R,V)),_Shinness);

				//在没有镜面反射的地方依然是漫反射,所以使用加法
				//o.col += _SpecluarColor * specularValue;
				//这一部分就是镜面反射(使用reflect函数求得的镜面反射就叫做Phone光照模型)
				//===================================================

				//上面两块加起来就是一个标准的Phone光照模型(环境光+漫反射+镜面反射)
				//===========================================================================================

				//===========================================================================================
				//blinnPhone模型(比Phone模型少了一个dot运算,因此更快)

				//首先取得半角向量(光向量+视向量)
				float3 H = L + V;

				//单位化
				H = normalize(H);

				//根据视向量和法向量的点积就可以得到镜面反射(单位化之后的法向量和半角向量的点积正好可以表现出当视角和光向量的反射向量越重合时镜面反射越强,反之越弱)
				//因为当光的反射向量正好和视向量重合时,这个时候的半角向量正好就是顶点的法向量(镜面强度最强),所以当视向量越偏离光的反射向量时半角向量也会越偏离法向量
				float specularValue = pow(saturate(dot(N,H)),_Shinness);
				o.col += _SpecluarColor * specularValue;
				//==============================================================================================

				return o;
			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				return IN.col;
			}
			ENDCG
		}
	}
}
