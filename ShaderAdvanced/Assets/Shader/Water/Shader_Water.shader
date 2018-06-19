Shader "Unlit/Shader_Water"
{
	Properties
	{
		_BumpTex ("Texture", 2D) = "white" {}
		_WaterCol("WaterCol",Color) = (1,1,1,1)
		_SpecCol("SpecCol",Color) = (1,1,1,1)
		_FresnelOffset("FresnelOffset",range(0,1)) = 0
		_Scale("Scale",range(0,1)) = 0
		_Strength("Strength",range(1,5)) =1
		_LightPow("LightPow",range(0,1)) =0.5
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
			#include "Lighting.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 proj:TEXCOORD1;
				float3 L:TEXCOORD2;
				float3 V:TEXCOORD3;
 				float4 vertex : SV_POSITION;
			};

			sampler2D _BumpTex;
			sampler2D _GrabTexture;
			float4 _BumpTex_ST;
			fixed4 _WaterCol;
			fixed4 _SpecCol;
			float _FresnelOffset,_Scale,_Strength,_LightPow;
			
			v2f vert (appdata_tan v)
			{
				v2f o;

				//首先将顶点转换到世界空间矩阵
				o.vertex = UnityObjectToClipPos(v.vertex);

				//然后在转到投影空间矩阵
				o.proj = ComputeGrabScreenPos(o.vertex);

				float3 Local_Light = ObjSpaceLightDir(v.vertex);//转换到本地坐标空间,因为下面要转换到纹理空间所以这里需要先转换到本地空间

				float3 Local_View = ObjSpaceViewDir(v.vertex);

//				//得到切向量
//				float3 T = normalize(v.tangent);
//
//				//得到法向量
//				float3 N = normalize(v.normal);
//
//				//得到T和N的叉积(垂直于N和T所组成的平面)的向量
//				float3 TCrossN = cross(N,T);

				//float3x3 Texture_Matrix = float3x3(T,TCrossN,N);

				//使用Unity的内置宏来计算纹理空间矩阵rotation
				TANGENT_SPACE_ROTATION;

				//将光向量转换到纹理空间,因为要采样法线贴图,如果不转换到纹理空间,那么法线贴图采样就会出问题
				o.L = mul(rotation,Local_Light);

				o.V = mul(rotation,Local_View);

				o.uv = TRANSFORM_TEX(v.texcoord, _BumpTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//将法线贴图重复采样形成水流的效果
				//第一次采样在X方向上加上时间因子
				fixed4 col_1 = tex2D(_BumpTex, i.uv+float2(_Time.x,0));
				fixed4 col_2 = tex2D(_BumpTex, i.uv+float2(0,_Time.x));
				//第一次采样在y方向上加上时间因子
				//fixed4 col_2 = tex2D(_BumpTex, float2(i.uv.y,i.uv.x)+float2(_Time.x,0));
				//求平均值
				fixed4 col = (col_1+col_2)/2;

				//通过采样法线贴图得到法线
				float3 N = normalize(UnpackNormal(col));

				//现在跟之前的法线(因为是plane,之前的法线就是float3(0,1,0))进行dot,从而得到一个折射率,使得水面有一种折射的效果
				float offset_uv = dot(N,float3(0,1,0));

				i.proj.xy = i.proj.xy+offset_uv;

				//抓取通道uv偏移的颜色(水面折射的颜色)
				fixed4 ProjCol = tex2Dproj(_GrabTexture,i.proj);

				//与水自身的颜色相乘
				ProjCol*= _WaterCol;

				//漫反射系数
				float diff = saturate(dot(N,normalize(i.L)));

				//漫反射
				float4 diffCol = _LightColor0*diff;

				//半角向量(两个向量相加或者dot时一定要normalize,不然会出现黑斑)
				float3 H = normalize((normalize(i.L)+normalize(i.V)));

				//高光系数
				float spec = pow(dot(H,N),64);

				//高光颜色
				fixed4 SpecColor = _SpecCol*spec;

				//漫发射和高光(两个加起来会显得很亮,加个_LightPow控制下亮度)
				fixed4 LightCol = (diffCol + SpecColor)*_LightPow;

				//菲尼尔系数
				float Fresnel = _FresnelOffset + _Scale*pow(1-dot(N,normalize(i.V)),_Strength);

				//最终输出颜色
				//ProjCol.rgb *= LightCol.rgb;

				//return ProjCol;

				return lerp(ProjCol,LightCol,Fresnel);//通过菲尼尔系数来确定当摄像机处于不同位置时哪些地方更应该是折射(摄像机越垂直越是折射),哪些地方更应该是发射(摄像机越偏越反射,光的颜色)
			}
			ENDCG
		}
	}
}
