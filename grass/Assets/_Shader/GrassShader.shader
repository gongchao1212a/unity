
Shader "Custom/GrassShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("NoiseTex",2D) ="white"{}
		_WindAngle("WindAngle",Range(0,360)) = 45
		_WindStrength("WindStrength",Range(0,10)) = 1

	}
	SubShader
	{
		Cull OFF// 2、关闭背面裁剪
		Tags { "RenderType"="Transparent" "Opaque" = "Transparent"  "IgnoreProjector"="True" }// 1、设置渲染队列为透明
		
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			ZWrite Off
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _WindAngle;
			float _WindStrength;
			
			v2f vert (appdata v)
			{
				v2f o;

				// 3、在世界坐标系下对草的坐标进行扰动
				float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
				float rangle = _WindAngle * sin(worldPos.x + worldPos.z);
				//5、添加风速
				float a = (2 * 3.1415926) / 360 *  rangle;


				//  6、添加周期性
				float windLenght = (sin(_Time.y * 5 ) - 0.5) * _WindStrength;			
				worldPos.x = worldPos.x + windLenght * sin(a) * v.uv.y;
				worldPos.z = worldPos.z + windLenght * cos(a) * v.uv.y;
				// 4、将变换化的世界坐标系转成模型坐标
				float4 modelPos = mul(unity_WorldToObject,worldPos);
				o.vertex = UnityObjectToClipPos(modelPos);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
			
				return col;
			}
			ENDCG
		}
	}
}
