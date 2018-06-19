Shader "Unlit/Shader_RealTimeShadow"
{
	//本Shader是使用于地面的
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

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
				float4 vertex : SV_POSITION;
				float4 uv_Porject:TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//投影相机所渲染的物体的z值保存在这张深度贴图中(一张RenderTexture)
			sampler2D _ShadowTexture;

			//这个矩阵是通过来自C#的投影相机的投影矩阵(cam.projectionMatrix),视矩阵(cam.worldToCameraMatrix)和透视纹理矩阵相乘得来,后面还要和unity_ObjectToWorld相乘来得到投影相机的透视空间矩阵(因为这样才能使用tex2Dproj表达投影效果),然后利用这个矩阵来对_DepthTexture进行透视投影采样就可以得到投影物体的z值
			float4x4 _ProjectMatrix;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP,v.vertex);
				//和unity_ObjectToWorld相乘最终得到投影相机的透视空间矩阵
				_ProjectMatrix = mul(_ProjectMatrix,unity_ObjectToWorld);

				//得到透视纹理采样的uv(已转换到投影相机的透视空间中)
				//使用ComputeScreenPos这个方法就相当于拥有了透视投影矩阵(normalMatrix)的效果,所以这里就解释了为什么C#不用再传normalMatrix到Shader里了
				//在调用ComputeScreenPos的方法之前所有的矩阵运算实际上就是MVP,所以理论上来说直接使用ComputeScreenPos(o.vertex)应该是一样的效果,但是这里不能这样
				//因为这里的UNITY_MATRIX_MVP是相对主相机的UNITY_MATRIX_MVP,而你的影子是C#里新建的一个相机ProjectorCam投射出来的,所以这里的UNITY_MATRIX_MVP并不是ProjectorCam的UNITY_MATRIX_MVP,而它的VP需要从C#里传进来,而世界矩阵unity_ObjectToWorld是不变的
				o.uv_Porject = ComputeScreenPos(mul(_ProjectMatrix,v.vertex));


				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//采样深度纹理,要准确的将投影的效果表达出来,就要使用tex2Dproj这个CG函数,这个函数的uv是要经过透视纹理矩阵变换的,它的变换顺序为normalMatrix*projectionMatrix*worldToCameraMatrix*unity_ObjectToWorld
				fixed4 dcol = tex2Dproj(_ShadowTexture,i.uv_Porject);

				//解码,因为在深度纹理产生的时候是经过EncodeFloatRGBA编码的
				//通过深度纹理采样方式获取阴影
				//float d = DecodeFloatRGBA(dcol);

				float ShadowScale = 1;

				//当深度纹理中的z值小于1时就说明深度纹理的该地方是被写入了深度缓存的,也就是说当投影物体的深度被写入的地方z值就是小于1的,那么这个地方就应该会产生影子,其他地方没写入深度缓存,值为1就没有影子
				//if( d<1)
					//ShadowScale = 0.5;

				//通过渲染图的alpha是是否大于0的方式获得阴影
				if(dcol.a > 0)
					ShadowScale = 0.5;

				fixed4 col = tex2D(_MainTex,i.uv)*ShadowScale;

				return col;
			}
			ENDCG
		}
	}
}
