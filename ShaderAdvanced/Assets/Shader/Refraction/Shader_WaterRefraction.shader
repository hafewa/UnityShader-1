Shader "Unlit/Shader_WaterRefraction"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		//波长
		_L("L",range(1,10)) = 1

		//振幅
		_A("A",range(0.01,0.1)) = 0.01

		//波传播的速度
		_S("S",range(1,20)) = 1
	}
	SubShader
	{
		//半透明物体要加上"queue"="transparent"
		Tags { "RenderType"="Opaque" "queue"="transparent"}
		LOD 100

		//这个是Unity内建的抓取屏幕的通道,只要定义了这个pass,在下面的pass中就可以得到一张将当前屏幕的渲染抓取到一张纹理_GrabTexture
		GrabPass{}


		//还有一种方式是不使用GrabPass,因为比较耗性能,我们使用像实时阴影渲染的那个Rendertexture一样,也用一张Rendertexture来替换_GrabTexture


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
				float3 N:Normal;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//从GrabPass获取,其实这个_GrabTexture就是实时投影例子里的那张存投影物体的Rendertexture
			//不过使用GrabPass{},Unity官方说明效率不高
			sampler2D _GrabTexture;

			//RnederTexture的方式
			//sampler2D _ProjectTexture;

			//RnederTexture的方式
			//float4x4 _ProjectMatrix;

			float _L;
			float _A;
			float _S;
			
			v2f vert (appdata v)
			{
				float w = 2*3.14159/_L;
				float f = _S * w;
				//顶点变换,根据完整水波公式(v.vertex.xz就是公式中的D,是指的水波在哪个平面内传播)
				v.vertex.y+= _A*sin(-length( v.vertex.xz*w) + _Time.y*f);

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				//这个函数来自UnityCG.cginc,它的作用就是就把通过mvp变换后的顶点再乘以透视纹理矩阵转换到透视空间,然后再frag中就可以通过o.proj来采样抓取纹理_GrabTexture
				//这样就可以将地板floor投射到我们的water平面上来
				o.proj = ComputeGrabScreenPos(o.vertex);

				//RnederTexture的方式
				//从外部传进来的_ProjectMatrix,是由normalMatrix*projectionMatrix*worldToCameraMatrix相乘得来,然后再乘以unity_ObjectToWorld.就可以得到最后的透视空间矩阵
				//_ProjectMatrix = mul(_ProjectMatrix,unity_ObjectToWorld);
				//o.proj = mul(_ProjectMatrix,v.vertex);

				//对变换后的顶点(就是顶点y方向上的完整水波公式求偏导)在x方向上求偏导数(具体原理参见工程中该Shader同目录的图)
				//因为完整水波公式是一个复合函数的公式,其中sin(-length( v.vertex.xz*w) + _Time.y*f)本身是一个函数, v.vertex.xz*w也是一个函数
				//所以这里求偏导就要分开求导然后再相乘,将sin(-length( v.vertex.xz*w) + _Time.y*f)以x自变量求偏导就是cos(-length( v.vertex.xz*w) + _Time.y*f),_Time.y*f都是常量
				// v.vertex.xz*w以x自变量求偏导就是w *v.vertex.x(以x自变量求偏导实际上z方向上的变化率为0,所以v.vertex.z就直接去掉了,而x方向上的变化率为1,所以就保留v.vertex.x,w是常量)
				float dx = w *v.vertex.x  * _A*cos(-length( v.vertex.xz*w) + _Time.y*f);

				//对变换后的顶点(就是顶点y方向上的波形公式求偏导)在z方向上求偏导数(具体原理参见工程中该Shader同目录的图,同上)
				float dy = w *v.vertex.z  * _A*cos(-length( v.vertex.xz*w) + _Time.y*f);

				//在x方向和z方向都求了偏导数之后我们就可以得出该顶点在x,z方向上应该有什么样的变化率
				//根据以x自变量上求得的偏导数组合成一个x方向上的向量(这个向量也是实时变化的,其实就是x方向上的变换率的表现)
				float3 X = float3(1,dx,0);

				//根据y自变量上求得的偏导数组合成一个y方向上的向量(这个向量也是实时变化的,其实就是z方向上的变换率的表现)
				float3 Y = float3(0,dy,1);

				//用这两个向量叉乘就可以得到顶点变换后的新的法线
				//o.N = cross(X,Y);

				//优化cross,实际上就是展开cross的算法
				o.N = float3(dx,-1,dy);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//fixed4 col = tex2D(_MainTex, i.uv);

				//物体表面顶点的原始法线就是float(0,1,0),因为该物体是平面
				//与顶点变换之后所得到的新的法线进行dot
				float detla = dot(i.N,float3(0,1,0));

				i.proj += detla;

				fixed4 col = tex2Dproj(_GrabTexture,i.proj)*0.5;

				return col;
			}
			ENDCG
		}
	}
}
