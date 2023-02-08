Shader "Unlit/DissolveShader" {
    Properties {
		_Color ("Color", Color) = (1,1,1,1) //Color
		_MainTex ("Texture", 2D) = "white" {} //Texture
		_Smoothness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
 
		//Dissolve properties, in this case a 2D texture and value to determine how much should be rendered on the screen
		_DissolveTexture("Dissolve Texture", 2D) = "white" {} 
		_Value("Amount", Range(0,1)) = 0
	}

	SubShader {
		Tags { "RenderType"="Opaque" } //Tags for rendering, in this case opaque
 
		//Surface Shader compile directives, it follows the structure of
		//#pragma surface 'surfaceFunction' lightModel [optionalparams]
		//where surfaceFunction has an input that is self-defined
		//Here we have support for all light shadow types in 'Forward' rendering path (each object is rendered in one or more passes)
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
        #include "UnityCG.cginc"

		//Accessing shader properties
		sampler2D _MainTex;
		sampler2D _DissolveTexture;
 
		struct Input {
			float2 uv_MainTex; //UV coordinates from the input
		};
 
		float _Smoothness;
		float _Metallic;
		float _Value;
		float4 _Color;

		//surf function with shadercode, the lighting model matches the standard shader in Unity
		//Surface/Fragment function
		void surf (Input i, inout SurfaceOutputStandard o) {
			
			//Dissolve function that gets how much it has to dissolve, depending on the texture provided
			float dissolve_value = tex2D(_DissolveTexture, i.uv_MainTex);
			clip(dissolve_value - _Value); //Clip discards any pixel with a value less than zero, aka. pixels will not be rendered
 
			//Shader function that outputs to the color
			float4 comb = tex2D (_MainTex, i.uv_MainTex) * _Color; 
 
			o.Albedo = comb; //Output to the base color of the texture
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
		}
		ENDCG
	}
	FallBack "Standard"
}
