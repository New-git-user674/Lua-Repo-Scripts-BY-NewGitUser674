using System;
using MoonSharp.Interpreter;

class Program
{
    static void Main(string[] args)
    {
        // Initialize MoonSharp
        Script.DefaultOptions.DebugPrint = s => Console.WriteLine("[lua] " + s);
        var script = new Script();

        Console.WriteLine("Simple Lua Executor (type 'exit' to quit)");
        while (true)
        {
            Console.Write("> ");
            var line = Console.ReadLine();

            if (line == null || line.Trim().ToLower() == "exit")
                break;

            if (string.IsNullOrWhiteSpace(line))
                continue;

            try
            {
                // Try to treat input as an expression first
                DynValue result;
                try
                {
                    result = script.DoString("return " + line);
                }
                catch
                {
                    // If that fails, treat it as a statement/block
                    result = script.DoString(line);
                }

                if (result != null && result.Type != DataType.Void && result.Type != DataType.Nil)
                {
                    Console.WriteLine(result.ToString());
                }
            }
            catch (ScriptRuntimeException ex)
            {
                Console.WriteLine("Lua error: " + ex.DecoratedMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Host error: " + ex.Message);
            }
        }
    }
}
