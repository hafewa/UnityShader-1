// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


//投影是需要像素光源的,顶点光源是不会投影的

//因此想让点光源有投影必须使用ForwardAdd pass
Shader "Sbin/DiffuseShadow"
{
	properties
	{
		_MainTex("MainTex",2D) =  "white" {}
	}
	SubShader
	{
		//如果想让渲染的物体能够受到平行光的影响投影到别的物体上,加上这个pass(里面只需tags{"lightmode" = "ShadowCaster"})即可
		//但是被投影的物体要能接收阴影
		//但是这样还是不会投影点光源的影子(不会受到点光源的影响)
//		pass
//		{
//			tags{"lightmode" = "ShadowCaster"}
//		}

		Pass
		{
			//漫反射光照的光照模式ForwardBase
			tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//这个是多版本shader编译,加上这句话之后系统就会自动判断当前场景中是否含有平行光,点光源,聚光灯,并给下面的接收投影宏进行不同的代码替换
			//详见AutoLight.cginc中各种类型的灯光接收投影的宏定义
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"
			#include "lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 lightdir:COLOR;
				float4 vertex:TEXCOORD2;
				float3 normal:TEXCOORD3;
				float2 uv:TEXCOORD4;

				//创建投影接收者数据类型
				//来自autolight.cginc
				//该宏末尾有分号,所以不用加分号了
				//该物体能够接收影子第一步
				LIGHTING_COORDS(0,1)
			};

			sampler2D _MainTex;
			v2f vert (appdata_base v)
			{
				v2f o;
			
				//将法线变换到世界空间的标准写法
				float3 N =  UnityObjectToWorldNormal(v.normal);

				float3 L = normalize(WorldSpaceLightDir(v.vertex));

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				float4 wpos = mul(unity_ObjectToWorld,v.vertex);

				o.vertex = normalize(wpos);

				o.lightdir.xyz = L;

				o.normal = N;
				o.uv = v.texcoord;

				//仅仅只能在Vertex光照模型下才能使用的方法
				//o.color.rgb = ShadeVertexLights(v.vertex,v.normal);

				//仅仅只在ForwardBase光照模型下才能使用的方法
				//这个方法要放在顶点程序中使用才有效,因为ForwardBase的渲染路径相对于点光源只支持顶点程序(逐顶点的),不支持片段程序(逐像素的)

				//这里注释是因为当添加了ForwardAdd的pass后,目的就是为了使得点光源按照逐像素计算的,但是点光源按照逐像素计算后就没必要在ForwardBase的顶点程序中再计算点光源按照逐顶点计算,这样就重复了,导致效果不对
//				o.PointLightCol = Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
//												unity_LightColor[0].rgb,unity_LightColor[1].rgb,
//												unity_LightColor[2].rgb,unity_LightColor[3].rgb
//												,unity_4LightAtten0,wpos.xyz,N);

				//来自autolight.cginc
				//该宏末尾有分号,所以不用加分号了
				//该物体能够接收影子第二步
				//将投影数据赋值并传递到片段着色器中
				TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;

			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				float Dot = saturate(dot(IN.normal,IN.lightdir));

				//在片段程序中计算平行光的漫反射
				//这里的_LightColor0是平行光
				fixed4 col = tex2D(_MainTex,IN.uv) * _LightColor0 * Dot;

				//来自autolight.cginc
				//该物体能够接收影子第三步
				//这一步实际上是计算影子和光照强度的衰减
				//这3步完成后该物体就可以接收平行光(还不支持点光源,因为在ForwardBase渲染路径下点光源是不支持按像素渲染的,因此要想使得该物体也能接收点光源的投影就要加一个pass(ForwardAdd))的投影了

				//4.x的方法
				//float4 atten = LIGHT_ATTENUATION(IN);

				//5.0+的方法
				//atten是在宏中声明的
				UNITY_LIGHT_ATTENUATION(atten,IN,IN.vertex.xyz)
				return (col + UNITY_LIGHTMODEL_AMBIENT) * atten;
			}
			ENDCG
		}

		//========================================================
		//这个pass专门来处理像素光源(点光源)的接收投影（但是这个pass并不会处理主要的平行光）
		Pass
		{
			//ForwardAdd光照模型是有一个像素光源,此pass就是执行一次
			//想让点光源也是逐像素渲染的就必须加这个ForwardAdd pass
			tags{"LightMode"="ForwardAdd"}

			//因为要保留在上一个pass中的平行光的阴影,所有这里使用one one
			blend one one
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			//全部阴影的多版本编译(包含所有像素光源(点光源,平行光,聚光灯))
			#pragma multi_compile_fwdadd_fullshadows

			#include "UnityCG.cginc"
			#include "lighting.cginc"
			#include "AutoLight.cginc"

			struct v2f
			{
				float4 pos:POSITION;
				fixed4 lightdir:COLOR;
				float4 vertex:TEXCOORD2;
				float3 normal:TEXCOORD3;
				float2 uv:TEXCOORD4;

				//创建投影接收者数据类型
				//来自autolight.cginc
				//该宏末尾有分号,所以不用加分号了
				//该物体能够接收影子第一步
				LIGHTING_COORDS(0,1)
			};

			sampler2D _MainTex;
			v2f vert (appdata_base v)
			{
				v2f o;

				//将法线变换到世界空间的标准写法
				float3 N = UnityObjectToWorldNormal(v.normal);

				float3 L = normalize(WorldSpaceLightDir(v.vertex));

				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);

				o.lightdir.xyz = L;

				o.vertex = mul(unity_ObjectToWorld,v.vertex);

				o.normal = N;
				o.uv = v.texcoord;

				//来自autolight.cginc
				//该宏末尾有分号,所以不用加分号了
				//该物体能够接收影子第二步
				//将投影数据赋值并传递到片段着色器中
				TRANSFER_VERTEX_TO_FRAGMENT(o)

				return o;

			}
			
			fixed4 frag (v2f IN) : COLOR
			{
				//在片段程序中计算漫反射
				float Dot = saturate(dot(IN.normal,IN.lightdir.xyz));

				//这里面的_LightColor0就是点光源了
				fixed4 col = tex2D(_MainTex,IN.uv) * _LightColor0 * Dot;

	
				//在ForwardAdd里是不支持这个方法的,Unity文档写的,视频中是不对的
//				col.rgb += Shade4PointLights(unity_4LightPosX0,unity_4LightPosY0,unity_4LightPosZ0,
//												unity_LightColor[0].rgb,unity_LightColor[1].rgb,
//												unity_LightColor[2].rgb,unity_LightColor[3].rgb
//												,unity_4LightAtten0,IN.vertex.xyz,IN.normal);

				//加上这一步才能使得该物体接收点光源投影而且还能计算影子和光照强度的衰减
				//4.x的方法
				//float4 atten = LIGHT_ATTENUATION(IN);

				//5.0+的方法
				//atten是在宏中声明的
				UNITY_LIGHT_ATTENUATION(atten,IN,IN.vertex.xyz)

				//在上一个pass中已经包含UNITY_LIGHTMODEL_AMBIENT环境光了
				return col * atten;
			}
			ENDCG
		}
	}

	//只要加了这句话就会既有点光源投影也会有平行光投影,但是要把上边的pass(tags{"lightmode" = "ShadowCaster"})去掉
	//这个意思是物体设置了投影到其他物体上,但是shader中并没有投影代码的话它就会去找系统中设置投影的代码
	//并不是直接使用了Diffuse着色器
	//5.0之前的Legacy/Shader/Diffuse着色器在forward渲染路径下并不能支持点光源的投影,要使用这个shader支持点光源投影的话就要设置LegacyDeferred延迟渲染路径
	//5.0之后只要选择Standard着色器(包含BRDF和GI光照模型)就可以在forward渲染路径支持点光源的投影
	//以上的描述都是投影到其他物体,还需有个能接收投影的物体
	fallback "Diffuse"
}
